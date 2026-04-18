import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/print_labels/label_border_sheet.dart';
import 'package:nahpu/screens/print_labels/label_canvas_stack.dart';
import 'package:nahpu/screens/print_labels/label_outline.dart';
import 'package:nahpu/screens/print_labels/label_size_selector.dart';
import 'package:nahpu/screens/print_labels/label_template_fonts.dart';
import 'package:nahpu/screens/print_labels/label_template_live_preview.dart';
import 'package:nahpu/screens/print_labels/label_gender_icon.dart';
import 'package:nahpu/screens/print_labels/label_pdf_service.dart';
import 'package:nahpu/screens/print_labels/label_template_model.dart';
import 'package:nahpu/services/label_logo_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:path/path.dart' as path;

/// PDF points per mm (72 / 25.4); keep in sync with `labelPdfMmToPt`.
const double _kPdfPointsPerMm = 72.0 / 25.4;

/// Invisible margin around the label so resize/rotate controls that paint outside
/// the white rect still receive hit tests (tight [SizedBox] would drop them).
const double _kLabelCanvasHitPadPx = 72.0;

/// Pixels → mm along label axes (mirror, scroll, nested transforms).
/// [globalDelta] must be in **global** logical pixels (not [DragUpdateDetails.delta],
/// which is local to the gesture target and wrong under [Transform.rotate]).
typedef LabelPanMmDeltaCallback = Offset? Function(
    Offset globalPosition, Offset globalDelta);

/// Logical px → mm along label axes; avoids div-by-zero before layout settles.
double _canvasScaleForMmMath(double scale) => scale < 1e-9 ? 1e-9 : scale;

double _clampMm(double value, double bound1, double bound2) {
  final lo = bound1 <= bound2 ? bound1 : bound2;
  final hi = bound1 <= bound2 ? bound2 : bound1;
  if (value.isNaN || value.isInfinite) return lo;
  return value.clamp(lo, hi);
}

class LabelTemplateEditorScreen extends ConsumerStatefulWidget {
  const LabelTemplateEditorScreen({super.key});

  @override
  ConsumerState<LabelTemplateEditorScreen> createState() =>
      _LabelTemplateEditorScreenState();
}

class _LabelTemplateEditorScreenState
    extends ConsumerState<LabelTemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LabelTemplateService _templateService = const LabelTemplateService();
  final LabelSettingsServices _labelSettings = LabelSettingsServices();

  LabelTemplate _template = DefaultLabelTemplate.defaultTemplate();
  List<String> _savedNames = [];
  bool _loading = true;
  double _zoom = 1.0;
  bool _showGrid = true;
  late bool _isDuplex;
  late bool _mirrorFront;
  late bool _mirrorBack;
  late double _labelWidthMm;
  late double _labelHeightMm;

  /// Currently selected element for the properties panel.
  /// Format: `builtin:<componentId>`, `custom:<page>:<ct_id>`, or `image:<page>:<img_id>`.
  String? _selectedElement;

  /// Custom text key (`custom:1:ct_0`) when typing on the canvas; null = preview only.
  String? _inlineCanvasCustomKey;

  int _customIdCounter = 0;
  int _imageIdCounter = 0;

  /// Bumps when the logo folder gains a file so [FutureBuilder] strips reload.
  int _logoLibraryEpoch = 0;

  /// First specimen’s `[field]` map for canvas preview (sex icons, etc.).
  Map<String, String> _editorLabelFieldPreview = {};

  bool _fieldsPanelExpanded = false;

  /// Non-null while a custom text box is in canvas inline edit; inserts at caret.
  void Function(String)? _inlineCustomTextPaste;

  bool _labelBorderPanelOpen = false;
  int _labelBorderPanelSession = 0;

  final GlobalKey _labelStackKeyPage1 = GlobalKey();
  final GlobalKey _labelStackKeyPage2 = GlobalKey();

  bool _imageTemplateFlushScheduled = false;
  CustomImageElement? _pendingImageTemplate;
  bool? _pendingImageTemplatePage1;

  bool _textTemplateFlushScheduled = false;
  CustomTextElement? _pendingTextTemplate;
  bool? _pendingTextTemplatePage1;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  void _scheduleTemplateImageUpdate(bool page1, CustomImageElement element) {
    _pendingImageTemplate = element;
    _pendingImageTemplatePage1 = page1;
    if (_imageTemplateFlushScheduled) return;
    _imageTemplateFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _imageTemplateFlushScheduled = false;
      if (!mounted) return;
      final el = _pendingImageTemplate;
      final p = _pendingImageTemplatePage1;
      _pendingImageTemplate = null;
      _pendingImageTemplatePage1 = null;
      if (el == null || p == null) return;
      setState(() {
        if (p) {
          _template = _template.copyWith(
            page1: _template.page1.withCustomImage(el),
          );
        } else {
          _template = _template.copyWith(
            page2: _template.page2.withCustomImage(el),
          );
        }
      });
    });
  }

  void _scheduleTemplateTextPositionUpdate(
    bool page1,
    CustomTextElement element,
  ) {
    _pendingTextTemplate = element;
    _pendingTextTemplatePage1 = page1;
    if (_textTemplateFlushScheduled) return;
    _textTemplateFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textTemplateFlushScheduled = false;
      if (!mounted) return;
      final el = _pendingTextTemplate;
      final p = _pendingTextTemplatePage1;
      _pendingTextTemplate = null;
      _pendingTextTemplatePage1 = null;
      if (el == null || p == null) return;
      setState(() {
        if (p) {
          _template = _template.copyWith(
            page1: _template.page1.withCustomText(el),
          );
        } else {
          _template = _template.copyWith(
            page2: _template.page2.withCustomText(el),
          );
        }
      });
    });
  }

  /// Maps a screen drag to label-space mm delta using the label [Stack]’s coords.
  Offset? _labelPanGlobalDeltaToMm(
    GlobalKey stackKey,
    Offset globalPosition,
    Offset globalDelta,
    double scale,
  ) {
    final ctx = stackKey.currentContext;
    if (ctx == null) return null;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.hasSize) return null;
    final p1 = ro.globalToLocal(globalPosition);
    final p0 = ro.globalToLocal(globalPosition - globalDelta);
    return Offset(
      (p1.dx - p0.dx) / scale,
      (p1.dy - p0.dy) / scale,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabControllerTick);
    _loadInitial();
  }

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  Future<void> _loadInitial() async {
    _isDuplex = await _labelSettings.getDuplex();
    _mirrorFront = await _labelSettings.getMirrorFront();
    _mirrorBack = await _labelSettings.getMirrorBack();
    _labelWidthMm = await _labelSettings.getLabelWidthMm();
    _labelHeightMm = await _labelSettings.getLabelHeightMm();
    final currentName = await _labelSettings.getCurrentTemplateName();
    if (currentName != null && currentName.isNotEmpty) {
      final t = await _templateService.getTemplate(currentName);
      if (t != null) {
        _template = t;
        final o = t.printOptions;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
          await _labelSettings.setDuplex(_isDuplex);
          await _labelSettings.setMirrorFront(_mirrorFront);
          await _labelSettings.setMirrorBack(_mirrorBack);
        }
      }
    }
    _syncDuplexTabIndex();
    _savedNames = await _templateService.listTemplateNames();
    _syncIdCountersFromTemplate();
    await _loadEditorLabelFieldPreview();
    if (mounted) {
      setState(() => _loading = false);
      unawaited(_warmCustomTextGoogleFonts());
    }
  }

  Future<void> _loadEditorLabelFieldPreview() async {
    try {
      final list = await SpecimenServices(ref: ref).getSpecimenList();
      if (list.isEmpty) return;
      final db = ref.read(databaseProvider);
      final m = await fieldValuesForSpecimen(db, list.first);
      if (mounted) setState(() => _editorLabelFieldPreview = m);
    } catch (_) {}
  }

  Future<void> _warmCustomTextGoogleFonts() async {
    try {
      for (final page in [_template.page1, _template.page2]) {
        for (final ct in page.customTexts) {
          if (!labelCanvasFontUsesGoogle(ct.fontFamily)) continue;
          await preloadGoogleFontForLabelCanvas(
            ct.fontFamily,
            ct.bold ? FontWeight.bold : FontWeight.normal,
            ct.italic ? FontStyle.italic : FontStyle.normal,
          );
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _syncDuplexTabIndex() {
    if (!_isDuplex && _tabController.index != 0) {
      _tabController.index = 0;
    }
  }

  LabelTemplatePrintOptions get _currentPrintOptions =>
      LabelTemplatePrintOptions(
        isDuplex: _isDuplex,
        mirrorFront: _mirrorFront,
        mirrorBack: _mirrorBack,
      );

  LabelTemplate _templateWithCurrentPrintOptions({String? name}) {
    return _template.copyWith(
      name: name,
      printOptions: _currentPrintOptions,
    );
  }

  void _syncIdCountersFromTemplate() {
    int textMax = 0;
    for (final ct in _template.page1.customTexts) {
      final n = int.tryParse(ct.id.replaceFirst('ct_', ''));
      if (n != null && n >= textMax) textMax = n + 1;
    }
    for (final ct in _template.page2.customTexts) {
      final n = int.tryParse(ct.id.replaceFirst('ct_', ''));
      if (n != null && n >= textMax) textMax = n + 1;
    }
    _customIdCounter = textMax;
    int imgMax = 0;
    for (final im in _template.page1.customImages) {
      final n = int.tryParse(im.id.replaceFirst('img_', ''));
      if (n != null && n >= imgMax) imgMax = n + 1;
    }
    for (final im in _template.page2.customImages) {
      final n = int.tryParse(im.id.replaceFirst('img_', ''));
      if (n != null && n >= imgMax) imgMax = n + 1;
    }
    _imageIdCounter = imgMax;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerTick);
    _tabController.dispose();
    super.dispose();
  }

  bool get _isPage1 => _tabController.index == 0;

  // --- Custom text helpers ---

  void _addCustomText(bool page1) {
    _addCustomTextWithLabel(page1, 'Text');
  }

  void _addCustomTextWithLabel(bool page1, String text) {
    final id = 'ct_$_customIdCounter';
    _customIdCounter++;
    final element = CustomTextElement(
      id: id,
      text: text,
      xMm: 5,
      yMm: 5,
    );
    final sel = 'custom:${page1 ? '1' : '2'}:$id';
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomText(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomText(element));
      }
      _selectedElement = sel;
      _inlineCanvasCustomKey = sel;
    });
  }

  void _updateCustomText(bool page1, CustomTextElement element) {
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomText(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomText(element));
      }
    });
  }

  void _deleteCustomText(bool page1, String id) {
    _deferSetState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withoutCustomText(id));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withoutCustomText(id));
      }
      if (_selectedElement == 'custom:${page1 ? '1' : '2'}:$id') {
        _selectedElement = null;
        _inlineCanvasCustomKey = null;
      }
    });
  }

  CustomTextElement? _findCustomText(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customTexts) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  void _removeCustomImage(bool page1, String imageId) {
    _deferSetState(() {
      if (page1) {
        _template = _template.copyWith(
          page1: _template.page1.withoutCustomImage(imageId),
        );
      } else {
        _template = _template.copyWith(
          page2: _template.page2.withoutCustomImage(imageId),
        );
      }
      final sel = 'image:${page1 ? '1' : '2'}:$imageId';
      if (_selectedElement == sel) {
        _selectedElement = null;
        _inlineCanvasCustomKey = null;
      }
    });
  }

  /// Picks an image file and copies it into the label logos folder; returns
  /// the stored path or null.
  Future<String?> _copyPickedImageToLogos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final filePath = result.files.single.path;
    if (filePath == null) return null;
    final ext = result.files.single.extension;
    const logoService = LabelLogoService();
    final added = ext != null && ext.isNotEmpty
        ? await logoService.addLogoFromFile(filePath)
        : await logoService.addLogoFromFileWithExtension(filePath, '.png');
    if (!mounted) return null;
    setState(() => _logoLibraryEpoch++);
    return added;
  }

  Future<void> _uploadAndUseImage(bool page1) async {
    final added = await _copyPickedImageToLogos();
    if (added == null) return;
    _placeCustomImage(page1, added);
  }

  Future<void> _showAddImageDialog(bool page1) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add image'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Upload from device'),
                  subtitle: const Text(
                    'Copies the file into your label images folder',
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _uploadAndUseImage(page1);
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(
                    'Saved images',
                    style: Theme.of(ctx).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: const LabelLogoService().listLogoPaths(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final paths = snap.data ?? [];
                      if (paths.isEmpty) {
                        return Center(
                          child: Text(
                            'No saved images yet — upload one first.',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: paths.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final p = paths[i];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: isLabelImagePathUsable(p)
                                  ? Image.file(
                                      File(p),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                        width: 44,
                                        height: 44,
                                        child:
                                            Icon(Icons.broken_image_outlined),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Icon(Icons.broken_image_outlined),
                                    ),
                            ),
                            title: Text(
                              path.basename(p),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _placeCustomImage(page1, p);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _placeCustomImage(bool page1, String filePath) {
    final id = 'img_$_imageIdCounter';
    _imageIdCounter++;
    final dw = (_labelWidthMm * 0.35).clamp(8.0, 48.0);
    final dh = (_labelHeightMm * 0.35).clamp(8.0, 48.0);
    final element = CustomImageElement(
      id: id,
      imagePath: filePath,
      xMm: 2,
      yMm: 2,
      widthMm: dw,
      heightMm: dh,
    );
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomImage(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomImage(element));
      }
      _selectedElement = 'image:${page1 ? '1' : '2'}:$id';
    });
  }

  // --- Save / Export / Import ---

  Future<void> _promptSaveTemplate() async {
    final ctrl = TextEditingController(text: _template.name.trim());
    final formKey = GlobalKey<FormState>();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save template'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Template name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter a name';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (name == null || !mounted) return;
      await _saveTemplateWithName(name);
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
  }

  /// When import would overwrite an existing saved template, user picks a new unique name.
  Future<String?> _promptImportNewName({
    required String conflictingName,
    required Set<String> takenNames,
  }) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save imported template as'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'Template name',
                hintText: 'Must differ from "$conflictingName"',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter a name';
                if (takenNames.contains(t)) {
                  return 'A template with this name already exists';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
  }

  Future<void> _saveTemplateWithName(String name) async {
    final merged = _templateWithCurrentPrintOptions(name: name);
    await _templateService.saveTemplate(merged);
    _savedNames = await _templateService.listTemplateNames();
    if (mounted) {
      setState(() => _template = merged);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved template "$name"')),
      );
    }
  }

  Future<void> _exportTemplate() async {
    final raw = _template.name.trim();
    final safe =
        raw.isEmpty ? 'template' : raw.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final suggested = 'label_template_$safe.json';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export label template',
      fileName: suggested,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (savePath == null || !mounted) return;
    final out =
        savePath.toLowerCase().endsWith('.json') ? savePath : '$savePath.json';
    try {
      final merged = _templateWithCurrentPrintOptions();
      await File(out).writeAsString(merged.toJsonString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${path.basename(out)}')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importTemplate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    final filePath = result.files.single.path!;
    final imported = await _templateService.importFromPath(filePath);
    if (imported != null && mounted) {
      final o = imported.printOptions;
      var name =
          imported.name.trim().isEmpty ? 'Imported' : imported.name.trim();
      var merged = imported.copyWith(
        name: name,
        printOptions: o ?? _currentPrintOptions,
      );
      final saved = await _templateService.listTemplateNames();
      if (!mounted) return;
      final taken = saved.toSet();
      if (taken.contains(name)) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Template exists'),
            content: Text(
              'A template named "$name" already exists. Replace the saved copy?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('New name'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace'),
              ),
            ],
          ),
        );
        if (replace == null || !mounted) return;
        if (!replace) {
          final newName = await _promptImportNewName(
            conflictingName: name,
            takenNames: taken,
          );
          if (newName == null || !mounted) return;
          name = newName;
          merged = merged.copyWith(name: name);
        }
      }
      await _templateService.saveTemplate(merged);
      if (!mounted) return;
      if (o != null) {
        await _labelSettings.setDuplex(o.isDuplex);
        await _labelSettings.setMirrorFront(o.mirrorFront);
        await _labelSettings.setMirrorBack(o.mirrorBack);
      }
      if (!mounted) return;
      _savedNames = await _templateService.listTemplateNames();
      if (!mounted) return;
      setState(() {
        _template = merged;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
        }
        _syncIdCountersFromTemplate();
        _syncDuplexTabIndex();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported and saved "$name"')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import failed or file invalid')),
      );
    }
  }

  Future<void> _loadTemplate(String name) async {
    final t = await _templateService.getTemplate(name);
    if (t != null) {
      await _labelSettings.setCurrentTemplateName(name);
      final o = t.printOptions;
      if (o != null) {
        await _labelSettings.setDuplex(o.isDuplex);
        await _labelSettings.setMirrorFront(o.mirrorFront);
        await _labelSettings.setMirrorBack(o.mirrorBack);
      }
      if (!mounted) return;
      setState(() {
        _template = t;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
        }
        _syncIdCountersFromTemplate();
        _selectedElement = null;
        _inlineCanvasCustomKey = null;
        _syncDuplexTabIndex();
      });
    }
  }

  bool get _canDeleteSavedTemplate {
    final n = _template.name.trim();
    return n.isNotEmpty && _savedNames.contains(n);
  }

  Future<void> _confirmDeleteTemplate() async {
    final name = _template.name.trim();
    if (!_canDeleteSavedTemplate) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete template'),
        content: Text(
          'Permanently delete "$name"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _templateService.deleteTemplate(name);
    _savedNames = await _templateService.listTemplateNames();
    final fresh = DefaultLabelTemplate.defaultTemplate();
    if (!mounted) return;
    await _labelSettings.setMirrorFront(false);
    await _labelSettings.setMirrorBack(false);
    _mirrorFront = false;
    _mirrorBack = false;
    _isDuplex = await _labelSettings.getDuplex();
    if (!mounted) return;
    setState(() {
      _template = fresh;
      _syncIdCountersFromTemplate();
      _selectedElement = null;
      _inlineCanvasCustomKey = null;
      _syncDuplexTabIndex();
    });
  }

  /// Mirror for the side currently being edited (front tab or single-sided).
  bool get _mirrorActiveForCurrentSide => _isPage1 ? _mirrorFront : _mirrorBack;

  String get _mirrorSideLabel =>
      _isDuplex ? (_isPage1 ? 'Front' : 'Back') : 'Front';

  Widget _buildMirrorToggleButton(BuildContext context) {
    final active = _mirrorActiveForCurrentSide;
    return IconButton.filledTonal(
      icon: const Icon(Icons.rotate_right),
      tooltip: active
          ? '$_mirrorSideLabel: rotated 180° for print (tap to turn off)'
          : '$_mirrorSideLabel: tap to rotate label 180° for print',
      onPressed: () async {
        if (_isPage1) {
          final next = !_mirrorFront;
          _deferSetState(() => _mirrorFront = next);
          await _labelSettings.setMirrorFront(next);
        } else {
          final next = !_mirrorBack;
          _deferSetState(() => _mirrorBack = next);
          await _labelSettings.setMirrorBack(next);
        }
      },
    );
  }

  /// Row 1: back button + title.
  Widget _buildBackButtonRow() {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge;
    return Material(
      elevation: 1,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          const BackButton(),
          Expanded(
            child: Text(
              'Label Editor',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop: combined header — back + title + duplex centered + border/grid/fields buttons.
  Widget _buildDesktopEditorHeader() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        theme.appBarTheme.titleTextStyle ??
        theme.textTheme.titleLarge;
    final duplexControl = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: false, label: Text('1 sided')),
          ButtonSegment(value: true, label: Text('2 sided')),
        ],
        selected: {_isDuplex},
        onSelectionChanged: (values) async {
          final duplex = values.first;
          _deferSetState(() {
            _isDuplex = duplex;
            if (!duplex && _tabController.index != 0) {
              _tabController.index = 0;
            }
            _selectedElement = null;
            _inlineCanvasCustomKey = null;
          });
          await _labelSettings.setDuplex(duplex);
        },
      ),
    );
    return Material(
      elevation: 1,
      surfaceTintColor: scheme.surfaceTint,
      color: scheme.surface,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BackButton(),
                      Expanded(
                        child: Text(
                          'Label Editor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                      ),
                    ],
                  ),
                  Center(child: duplexControl),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Label border',
              style: IconButton.styleFrom(
                foregroundColor: _labelBorderPanelOpen
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
                backgroundColor: _labelBorderPanelOpen
                    ? scheme.primaryContainer.withValues(alpha: 0.45)
                    : null,
              ),
              onPressed: () => _deferSetState(() {
                _labelBorderPanelOpen = !_labelBorderPanelOpen;
                if (_labelBorderPanelOpen) _labelBorderPanelSession++;
              }),
              icon: const Icon(Icons.border_outer, size: 22),
            ),
            IconButton(
              tooltip: _showGrid ? 'Hide grid' : 'Show grid',
              style: IconButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
              ),
              onPressed: () => _deferSetState(() => _showGrid = !_showGrid),
              icon: Icon(
                _showGrid ? Icons.grid_on : Icons.grid_off,
                size: 22,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildFieldsPanelToggleButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop: single toolbar row with page pickers + label size + tool buttons.
  Widget _buildDesktopTopToolbar() {
    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildFrontBackPagePickers(context),
                          if (_isDuplex) const SizedBox(width: 8),
                          if (_isDuplex) ...[
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 4,
                              endIndent: 4,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Label size:',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 168,
                                child: LabelSizeSelector(
                                  compact: true,
                                  controlledWidthMm: _labelWidthMm,
                                  controlledHeightMm: _labelHeightMm,
                                  onControlledDimensionsApplied: (w, h) {
                                    _deferSetState(() {
                                      _labelWidthMm = w;
                                      _labelHeightMm = h;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => _addCustomText(_isPage1),
                      icon: const Icon(Icons.text_fields),
                      tooltip: 'Add text',
                    ),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      onPressed: () => _showAddImageDialog(_isPage1),
                      icon: const Icon(Icons.image_outlined),
                      tooltip: 'Add image',
                    ),
                    const SizedBox(width: 4),
                    _buildMirrorToggleButton(context),
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      onPressed: _showPrintPreviewDialog,
                      icon: const Icon(Icons.print_outlined),
                      tooltip: 'Print preview',
                    ),
                  ],
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: _attributesBarOpen
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildLabelPanelAttributes(inToolbar: true),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile row 2: duplex toggle + border / grid / fields-panel buttons.
  Widget _buildEditorHeader() {
    final scheme = Theme.of(context).colorScheme;
    final duplexControl = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: false, label: Text('1 sided')),
          ButtonSegment(value: true, label: Text('2 sided')),
        ],
        selected: {_isDuplex},
        onSelectionChanged: (values) async {
          final duplex = values.first;
          _deferSetState(() {
            _isDuplex = duplex;
            if (!duplex && _tabController.index != 0) {
              _tabController.index = 0;
            }
            _selectedElement = null;
            _inlineCanvasCustomKey = null;
          });
          await _labelSettings.setDuplex(duplex);
        },
      ),
    );
    return Material(
      elevation: 1,
      surfaceTintColor: scheme.surfaceTint,
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            duplexControl,
            const Spacer(),
            IconButton(
              tooltip: 'Label border',
              style: IconButton.styleFrom(
                foregroundColor: _labelBorderPanelOpen
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
                backgroundColor: _labelBorderPanelOpen
                    ? scheme.primaryContainer.withValues(alpha: 0.45)
                    : null,
              ),
              onPressed: () => _deferSetState(() {
                _labelBorderPanelOpen = !_labelBorderPanelOpen;
                if (_labelBorderPanelOpen) _labelBorderPanelSession++;
              }),
              icon: const Icon(Icons.border_outer, size: 22),
            ),
            IconButton(
              tooltip: _showGrid ? 'Hide grid' : 'Show grid',
              style: IconButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
              ),
              onPressed: () => _deferSetState(() => _showGrid = !_showGrid),
              icon: Icon(
                _showGrid ? Icons.grid_on : Icons.grid_off,
                size: 22,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildFieldsPanelToggleButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontBackPagePickers(BuildContext context) {
    if (!_isDuplex) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onSurface;
    final frontActive = _tabController.index == 0;
    void clearSelection() => _deferSetState(() {
          _selectedElement = null;
          _inlineCanvasCustomKey = null;
        });

    TextStyle labelStyle(bool active) => TextStyle(
          fontSize: 15,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? scheme.primary : fg.withValues(alpha: 0.38),
        );

    Color mirrorColor(bool active) =>
        active ? scheme.primary : fg.withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            if (_tabController.index != 0) {
              _tabController.animateTo(0);
            }
            clearSelection();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: fg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Front', style: labelStyle(frontActive)),
              if (_mirrorFront) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.rotate_right,
                  size: 16,
                  color: mirrorColor(frontActive),
                ),
              ],
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            if (_tabController.index != 1) {
              _tabController.animateTo(1);
            }
            clearSelection();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: fg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Back', style: labelStyle(!frontActive)),
              if (_mirrorBack) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.rotate_right,
                  size: 16,
                  color: mirrorColor(!frontActive),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final isMobile = Platform.isIOS || Platform.isAndroid;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final headerRows = isMobile
        ? <Widget>[
            _buildBackButtonRow(),
            _buildEditorHeader(),
            if (isLandscape)
              ..._buildMobileLandscapeToolRows()
            else
              ..._buildMobilePortraitToolRows(),
          ]
        : <Widget>[
            _buildDesktopEditorHeader(),
            _buildDesktopTopToolbar(),
          ];

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: isMobile
                  ? EdgeInsets.only(
                      top: viewPadding.top,
                      left: viewPadding.left,
                      right: viewPadding.right,
                    )
                  : EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...headerRows,
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: _isDuplex
                              ? TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildCanvas(page1: true),
                                    _buildCanvas(page1: false),
                                  ],
                                )
                              : _buildCanvas(page1: true),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _buildZoomControls(),
                        ),
                      ],
                    ),
                  ),
                  if (_labelBorderPanelOpen) _buildLabelBorderPanel(),
                  _buildBottomEditorBar(),
                ],
              ),
            ),
          ),
          _buildAnimatedFieldsPanel(),
        ],
      ),
    );
  }

  Widget _buildLabelBorderPanel() {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      surfaceTintColor: scheme.surfaceTint,
      color: scheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, color: scheme.outlineVariant),
          LabelBorderEditorSheet(
            key: ValueKey<int>(_labelBorderPanelSession),
            initialOutline: _template.outline,
            embeddedPanel: true,
            maxHeightFraction: 0.36,
            onOutlineChanged: (o) {
              _deferSetState(() {
                if (o == null) {
                  _template = _template.copyWith(clearOutline: true);
                } else {
                  _template = _template.copyWith(outline: o);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPrintPreviewDialog() async {
    Map<String, String> sample = {};
    try {
      final list = await SpecimenServices(ref: ref).getSpecimenList();
      if (list.isNotEmpty) {
        final db = ref.read(databaseProvider);
        sample = await fieldValuesForSpecimen(db, list.first);
      }
    } catch (_) {}
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final sz = MediaQuery.sizeOf(ctx);
        final w = sz.width * 0.8;
        final h = sz.height * 0.8;
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SizedBox(
            width: w,
            height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Print preview',
                          style: Theme.of(ctx).textTheme.titleLarge,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      return LabelTemplateLivePreview(
                        viewportSize: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        showHeading: false,
                        template: _template,
                        isDuplex: _isDuplex,
                        mirrorFront: _mirrorFront,
                        mirrorBack: _mirrorBack,
                        labelWidthMm: _labelWidthMm,
                        labelHeightMm: _labelHeightMm,
                        placeholderValues: sample,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _pageAndLabelWidgets() {
    return [
      _buildFrontBackPagePickers(context),
      if (_isDuplex) const SizedBox(width: 8),
      if (_isDuplex) ...[
        VerticalDivider(
          width: 1,
          thickness: 1,
          indent: 4,
          endIndent: 4,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(width: 12),
      ],
      Text(
        'Label size:',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 168,
        child: LabelSizeSelector(
          compact: true,
          controlledWidthMm: _labelWidthMm,
          controlledHeightMm: _labelHeightMm,
          onControlledDimensionsApplied: (w, h) {
            _deferSetState(() {
              _labelWidthMm = w;
              _labelHeightMm = h;
            });
          },
        ),
      ),
    ];
  }

  List<Widget> _toolButtonWidgets() {
    return [
      IconButton.filledTonal(
        onPressed: () => _addCustomText(_isPage1),
        icon: const Icon(Icons.text_fields),
        tooltip: 'Add text',
      ),
      const SizedBox(width: 4),
      IconButton.filledTonal(
        onPressed: () => _showAddImageDialog(_isPage1),
        icon: const Icon(Icons.image_outlined),
        tooltip: 'Add image',
      ),
      const SizedBox(width: 4),
      _buildMirrorToggleButton(context),
      const SizedBox(width: 4),
      IconButton.filledTonal(
        onPressed: _showPrintPreviewDialog,
        icon: const Icon(Icons.print_outlined),
        tooltip: 'Print preview',
      ),
    ];
  }

  Widget _buildAttributesPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: _attributesBarOpen
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildLabelPanelAttributes(inToolbar: true),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }

  /// Portrait rows 3+4: page/label on one line, tool buttons on next.
  List<Widget> _buildMobilePortraitToolRows() {
    return [
      Material(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _pageAndLabelWidgets(),
            ),
          ),
        ),
      ),
      Material(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _toolButtonWidgets(),
              ),
              _buildAttributesPanel(),
            ],
          ),
        ),
      ),
    ];
  }

  /// Landscape: page/label + tool buttons merged into one row.
  List<Widget> _buildMobileLandscapeToolRows() {
    return [
      Material(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _pageAndLabelWidgets(),
                      ),
                    ),
                  ),
                  ..._toolButtonWidgets(),
                ],
              ),
              _buildAttributesPanel(),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomEditorBar() {
    final scheme = Theme.of(context).colorScheme;
    final hasTemplates = _savedNames.isNotEmpty;
    return Material(
      elevation: 4,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PopupMenuButton<String>(
                tooltip: hasTemplates ? 'Load template' : 'No saved templates',
                enabled: hasTemplates,
                icon: Icon(
                  Icons.folder_open_outlined,
                  color: hasTemplates
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.38),
                ),
                onSelected: (n) => _loadTemplate(n),
                itemBuilder: (ctx) => [
                  for (final n in _savedNames)
                    PopupMenuItem<String>(
                      value: n,
                      child: Text(
                        n,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _promptSaveTemplate,
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Save template',
              ),
              IconButton(
                onPressed: _exportTemplate,
                icon: const Icon(Icons.upload_file),
                tooltip: 'Export template',
              ),
              IconButton(
                onPressed: _importTemplate,
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Import template',
              ),
              IconButton(
                onPressed:
                    _canDeleteSavedTemplate ? _confirmDeleteTemplate : null,
                icon: Icon(
                  Icons.delete_outline,
                  color: _canDeleteSavedTemplate
                      ? scheme.error
                      : scheme.onSurface.withValues(alpha: 0.38),
                ),
                tooltip: 'Delete saved template',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.remove, size: 20),
              tooltip: 'Zoom out',
              onPressed: _zoom > 0.5
                  ? () => _deferSetState(
                        () => _zoom = (_zoom - 0.25).clamp(0.5, 4.0),
                      )
                  : null,
            ),
            Text(
              '${(_zoom * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Zoom in',
              onPressed: _zoom < 4.0
                  ? () => _deferSetState(
                        () => _zoom = (_zoom + 0.25).clamp(0.5, 4.0),
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas({required bool page1}) {
    final page = page1 ? _template.page1 : _template.page2;

    return LayoutBuilder(builder: (context, constraints) {
      const edgePadH = 16.0;
      const edgePadCanvasEnd = 0.0;
      final availW =
          (constraints.maxWidth - edgePadCanvasEnd).clamp(0.0, double.infinity);
      final availH =
          (constraints.maxHeight - 2 * edgePadH).clamp(0.0, double.infinity);
      final baseScale =
          (availW / _labelWidthMm).clamp(1.0, availH / _labelHeightMm);
      final scale = baseScale * _zoom;
      final canvasW = _labelWidthMm * scale;
      final canvasH = _labelHeightMm * scale;
      final stackW = canvasW + _kLabelCanvasHitPadPx;
      final stackH = canvasH + 2 * _kLabelCanvasHitPadPx;
      final scrollW = math.max(availW, stackW);
      final scrollH = math.max(availH, stackH);

      Offset? labelPanToMmDelta(Offset globalPosition, Offset globalDelta) {
        return _labelPanGlobalDeltaToMm(
          page1 ? _labelStackKeyPage1 : _labelStackKeyPage2,
          globalPosition,
          globalDelta,
          scale,
        );
      }

      return SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          primary: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              edgePadH,
              edgePadCanvasEnd,
              edgePadH,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: availW,
                minHeight: availH,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _deferSetState(() {
                    _selectedElement = null;
                    _inlineCanvasCustomKey = null;
                  });
                },
                child: Container(
                  width: scrollW,
                  height: scrollH,
                  alignment: Alignment.topLeft,
                  color: Colors.transparent,
                  child: Transform.rotate(
                    angle: (page1 ? _mirrorFront : _mirrorBack) ? math.pi : 0,
                    child: SizedBox(
                      width: stackW,
                      height: stackH,
                      child: LabelCanvasStack(
                        key: page1 ? _labelStackKeyPage1 : _labelStackKeyPage2,
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            left: 0,
                            top: _kLabelCanvasHitPadPx,
                            width: canvasW,
                            height: canvasH,
                            child: IgnorePointer(
                              child: Stack(
                                fit: StackFit.expand,
                                clipBehavior: Clip.none,
                                children: [
                                  DecoratedBox(
                                    decoration: labelAreaStackDecoration(),
                                    child: _showGrid
                                        ? CustomPaint(
                                            painter: _GridPainter(
                                              labelWidthMm: _labelWidthMm,
                                              labelHeightMm: _labelHeightMm,
                                              scale: scale,
                                            ),
                                            child: const SizedBox.expand(),
                                          )
                                        : const SizedBox.expand(),
                                  ),
                                  if (_template.outline != null)
                                    CustomPaint(
                                      painter: LabelOutlineOverlayPainter(
                                        outline: _template.outline!,
                                        scaleMmToPx: scale,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          for (final im in page.customImages)
                            _DraggableImageChip(
                              key: ValueKey(
                                  'p${page1 ? '1' : '2'}_img_${im.id}'),
                              imagePath: im.imagePath,
                              position: Offset(im.xMm, im.yMm),
                              widthMm: im.widthMm,
                              heightMm: im.heightMm,
                              rotationDegrees: im.rotationDegrees,
                              scale: scale,
                              labelWidthMm: _labelWidthMm,
                              labelHeightMm: _labelHeightMm,
                              canvasInsetXPx: 0,
                              canvasInsetYPx: _kLabelCanvasHitPadPx,
                              labelPanToMmDelta: labelPanToMmDelta,
                              isSelected: _selectedElement ==
                                  'image:${page1 ? '1' : '2'}:${im.id}',
                              onTap: () => _deferSetState(() {
                                _selectedElement =
                                    'image:${page1 ? '1' : '2'}:${im.id}';
                                _inlineCanvasCustomKey = null;
                              }),
                              onMoved: (pos) {
                                final maxX =
                                    math.max(0.0, _labelWidthMm - im.widthMm);
                                final maxY =
                                    math.max(0.0, _labelHeightMm - im.heightMm);
                                _scheduleTemplateImageUpdate(
                                  page1,
                                  im.copyWith(
                                    xMm: _clampMm(pos.dx, 0, maxX),
                                    yMm: _clampMm(pos.dy, 0, maxY),
                                  ),
                                );
                              },
                              onBoundsChanged: (x, y, w, h) {
                                _scheduleTemplateImageUpdate(
                                  page1,
                                  im.copyWith(
                                    xMm: x,
                                    yMm: y,
                                    widthMm: w,
                                    heightMm: h,
                                  ),
                                );
                              },
                              onRotationChanged: (deg) {
                                _scheduleTemplateImageUpdate(
                                  page1,
                                  im.copyWith(rotationDegrees: deg),
                                );
                              },
                              onDelete: () => _removeCustomImage(page1, im.id),
                            ),
                          for (final ct in page.customTexts)
                            if (labelGenderIconFieldKeyFromBracketText(ct.text)
                                case final gKey?)
                              _DraggableImageChip(
                                key: ValueKey(
                                  'p${page1 ? '1' : '2'}_gct_${ct.id}',
                                ),
                                imagePath: '',
                                vectorChild: Icon(
                                  labelGenderIconForFieldKey(
                                    _editorLabelFieldPreview,
                                    gKey,
                                  ),
                                ),
                                position: Offset(ct.xMm, ct.yMm),
                                widthMm: ct.iconWidthMm ??
                                    kLabelGenderIconDefaultWidthMm,
                                heightMm: ct.iconHeightMm ??
                                    kLabelGenderIconDefaultHeightMm,
                                rotationDegrees: ct.rotationDegrees,
                                scale: scale,
                                labelWidthMm: _labelWidthMm,
                                labelHeightMm: _labelHeightMm,
                                canvasInsetXPx: 0,
                                canvasInsetYPx: _kLabelCanvasHitPadPx,
                                labelPanToMmDelta: labelPanToMmDelta,
                                isSelected: _selectedElement ==
                                    'custom:${page1 ? '1' : '2'}:${ct.id}',
                                onTap: () => _deferSetState(() {
                                  _selectedElement =
                                      'custom:${page1 ? '1' : '2'}:${ct.id}';
                                  _inlineCanvasCustomKey = null;
                                }),
                                onMoved: (pos) {
                                  final wMm = ct.iconWidthMm ??
                                      kLabelGenderIconDefaultWidthMm;
                                  final hMm = ct.iconHeightMm ??
                                      kLabelGenderIconDefaultHeightMm;
                                  final maxX =
                                      math.max(0.0, _labelWidthMm - wMm);
                                  final maxY =
                                      math.max(0.0, _labelHeightMm - hMm);
                                  _scheduleTemplateTextPositionUpdate(
                                    page1,
                                    ct.copyWith(
                                      xMm: _clampMm(pos.dx, 0, maxX),
                                      yMm: _clampMm(pos.dy, 0, maxY),
                                    ),
                                  );
                                },
                                onBoundsChanged: (x, y, w, h) {
                                  _scheduleTemplateTextPositionUpdate(
                                    page1,
                                    ct.copyWith(
                                      xMm: x,
                                      yMm: y,
                                      iconWidthMm: w,
                                      iconHeightMm: h,
                                    ),
                                  );
                                },
                                onRotationChanged: (deg) {
                                  _scheduleTemplateTextPositionUpdate(
                                    page1,
                                    ct.copyWith(rotationDegrees: deg),
                                  );
                                },
                                onDelete: null,
                              )
                            else
                              _DraggableChip(
                                key: ValueKey(
                                    'p${page1 ? '1' : '2'}_ct_${ct.id}_${ct.rotationDegrees}_${ct.fontFamily}'),
                                label: ct.text.isEmpty ? '(empty)' : ct.text,
                                actualText: ct.text,
                                position: Offset(ct.xMm, ct.yMm),
                                fontSize: ct.fontSizePt,
                                fontFamily: ct.fontFamily,
                                bold: ct.bold,
                                italic: ct.italic,
                                rotationDegrees: ct.rotationDegrees,
                                scale: scale,
                                labelWidthMm: _labelWidthMm,
                                labelHeightMm: _labelHeightMm,
                                canvasInsetXPx: 0,
                                canvasInsetYPx: _kLabelCanvasHitPadPx,
                                labelPanToMmDelta: labelPanToMmDelta,
                                isCustom: true,
                                isInlineEditing: _inlineCanvasCustomKey ==
                                    'custom:${page1 ? '1' : '2'}:${ct.id}',
                                isSelected: _selectedElement ==
                                    'custom:${page1 ? '1' : '2'}:${ct.id}',
                                onInlineEditingComplete: (v) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (page1) {
                                      _template = _template.copyWith(
                                        page1: _template.page1.withCustomText(
                                          ct.copyWith(text: v),
                                        ),
                                      );
                                    } else {
                                      _template = _template.copyWith(
                                        page2: _template.page2.withCustomText(
                                          ct.copyWith(text: v),
                                        ),
                                      );
                                    }
                                    _inlineCanvasCustomKey = null;
                                    _inlineCustomTextPaste = null;
                                  });
                                },
                                onInlineTextInsertBinding: (fn) =>
                                    _deferSetState(() => _inlineCustomTextPaste = fn),
                                onTap: () {
                                  final k =
                                      'custom:${page1 ? '1' : '2'}:${ct.id}';
                                  setState(() {
                                    if (_selectedElement == k) {
                                      _inlineCanvasCustomKey = k;
                                    } else {
                                      _selectedElement = k;
                                      _inlineCanvasCustomKey = null;
                                    }
                                  });
                                },
                                onSelect: () {
                                  final k =
                                      'custom:${page1 ? '1' : '2'}:${ct.id}';
                                  setState(() {
                                    _selectedElement = k;
                                    _inlineCanvasCustomKey = null;
                                  });
                                },
                                onMoved: (pos) {
                                  _scheduleTemplateTextPositionUpdate(
                                    page1,
                                    ct.copyWith(
                                      xMm: pos.dx,
                                      yMm: pos.dy,
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFieldsPanelToggleButton() {
    final scheme = Theme.of(context).colorScheme;
    final open = _fieldsPanelExpanded;
    void toggle() =>
        _deferSetState(() => _fieldsPanelExpanded = !_fieldsPanelExpanded);

    if (open) {
      return IconButton.filledTonal(
        tooltip: 'Hide available fields',
        style: IconButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
        ),
        onPressed: toggle,
        icon: _EndSidebarPanelIcon(
          size: 22,
          color: scheme.onPrimaryContainer,
        ),
      );
    }
    return IconButton(
      tooltip: 'Show available fields',
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: toggle,
      icon: _EndSidebarPanelIcon(
        size: 22,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  double _measurePanelTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return tp.width;
  }

  /// One list row per label; `.sex` columns become two rows (`[id]`, `[id]-img`).
  List<String> _fieldPanelRowLabels(List<String> fieldIds) {
    final out = <String>[];
    for (final id in fieldIds) {
      if (id.toLowerCase().endsWith('.sex')) {
        out.add('[$id]');
        out.add('[$id]-img');
      } else {
        out.add('[$id]');
      }
    }
    return out;
  }

  /// Width to fit the widest line (title or field label) plus padding and [extra] px.
  double _availableFieldsPanelWidth(List<String> fieldIds, {double extra = 5}) {
    final titleStyle =
        Theme.of(context).textTheme.titleSmall ?? const TextStyle();
    final fieldStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.25,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final titleW = _measurePanelTextWidth('Available fields', titleStyle);
    var maxFieldW = 0.0;
    for (final id in fieldIds) {
      if (id.toLowerCase().endsWith('.sex')) {
        maxFieldW = math.max(
          maxFieldW,
          _measurePanelTextWidth('[$id]', fieldStyle),
        );
        maxFieldW = math.max(
          maxFieldW,
          _measurePanelTextWidth('[$id]-img', fieldStyle),
        );
      } else {
        maxFieldW = math.max(
          maxFieldW,
          _measurePanelTextWidth('[$id]', fieldStyle),
        );
      }
    }
    const titleHorizontalPadding = 20.0;
    const listHorizontalPadding = 21.0;
    final inner = math.max(
        titleW + titleHorizontalPadding, maxFieldW + listHorizontalPadding);
    return (inner + extra).clamp(80.0, 10000.0);
  }

  Widget _buildAnimatedFieldsPanel() {
    final fieldIds = labelTemplateAvailableFieldIds(ref.read(databaseProvider));
    final panelW = _availableFieldsPanelWidth(fieldIds);
    const divW = 1.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: _fieldsPanelExpanded ? divW + panelW : 0,
      child: UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: divW + panelW,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VerticalDivider(width: 1),
              SizedBox(
                width: panelW,
                child: _buildFieldsPanel(fieldIds: fieldIds, width: panelW),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldsPanel({
    required List<String> fieldIds,
    required double width,
  }) {
    final rowLabels = _fieldPanelRowLabels(fieldIds);
    return TextFieldTapRegion(
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: SizedBox(
          width: width,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Text(
                'Available fields',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: rowLabels.length,
                itemBuilder: (context, index) {
                  final label = rowLabels[index];
                  final fieldStyle = TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.25,
                    color: Theme.of(context).colorScheme.onSurface,
                  );
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    horizontalTitleGap: 8,
                    contentPadding: const EdgeInsets.fromLTRB(16, 2, 5, 2),
                    onTap: () {
                      final paste = _inlineCustomTextPaste;
                      if (paste != null) {
                        paste(label);
                      } else {
                        _addCustomTextWithLabel(_isPage1, label);
                      }
                    },
                    title: Text(
                      label,
                      style: fieldStyle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  bool get _attributesBarOpen {
    final sel = _selectedElement;
    return sel != null && sel.startsWith('custom:');
  }

  Widget _buildLabelPanelAttributes({bool inToolbar = false}) {
    final sel = _selectedElement;
    if (sel == null || !sel.startsWith('custom:')) {
      return const SizedBox.shrink();
    }
    return _buildCustomTextPanel(sel, inToolbar: inToolbar);
  }

  Widget _buildCustomTextPanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    if (parts.length != 3) return const SizedBox.shrink();
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ct = _findCustomText(page1, id);
    if (ct == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete text box',
      onPressed: () => _deleteCustomText(page1, id),
    );

    if (isLabelBracketGenderIconText(ct.text)) {
      final content = Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [deleteButton],
        ),
      );
      if (inToolbar) {
        return Material(
          elevation: 0,
          color: scheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: content,
        );
      }
      return Material(
        elevation: 2,
        color: scheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: content,
        ),
      );
    }

    final fontKey = normalizeLabelFontFamily(ct.fontFamily);
    final fontDropdownIds = List<String>.from(kLabelFontDropdownKeys);
    if (fontKey.isNotEmpty && !fontDropdownIds.contains(fontKey)) {
      fontDropdownIds.add(fontKey);
    }
    final content = Padding(
      padding: inToolbar
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Font', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: fontKey,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final k in fontDropdownIds)
                        DropdownMenuItem<String>(
                          value: k,
                          child: Text(labelFontDropdownLabel(k)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      _updateCustomText(page1, ct.copyWith(fontFamily: v));
                    },
                  ),
                  const SizedBox(width: 12),
                  Text('Size (pt)',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: _SyncedFontSizeField(
                      key: ValueKey('fs_$id'),
                      fontSizePt: ct.fontSizePt,
                      onValidSize: (p) => _updateCustomText(
                        page1,
                        ct.copyWith(fontSizePt: p),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    tooltip: 'Decrease font size',
                    onPressed: ct.fontSizePt > 4
                        ? () => _updateCustomText(
                              page1,
                              ct.copyWith(
                                  fontSizePt:
                                      (ct.fontSizePt - 0.5).clamp(4.0, 72.0)),
                            )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    tooltip: 'Increase font size',
                    onPressed: ct.fontSizePt < 72
                        ? () => _updateCustomText(
                              page1,
                              ct.copyWith(
                                  fontSizePt:
                                      (ct.fontSizePt + 0.5).clamp(4.0, 72.0)),
                            )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('Bold'),
                    selected: ct.bold,
                    onSelected: (v) =>
                        _updateCustomText(page1, ct.copyWith(bold: v)),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Italic'),
                    selected: ct.italic,
                    onSelected: (v) =>
                        _updateCustomText(page1, ct.copyWith(italic: v)),
                  ),
                  const SizedBox(width: 12),
                  Text('Rotation',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('0°')),
                      ButtonSegment(value: 90, label: Text('90°')),
                      ButtonSegment(value: -90, label: Text('-90°')),
                      ButtonSegment(value: 180, label: Text('180°')),
                    ],
                    selected: {ct.rotationDegrees},
                    onSelectionChanged: (next) {
                      if (next.isEmpty) return;
                      _updateCustomText(
                        page1,
                        ct.copyWith(rotationDegrees: next.first),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          deleteButton,
        ],
      ),
    );

    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable image on canvas (mm space)
// ---------------------------------------------------------------------------

enum _ImageCorner { tl, tr, bl, br }

class _DraggableImageChip extends StatefulWidget {
  const _DraggableImageChip({
    super.key,
    required this.imagePath,
    required this.position,
    required this.widthMm,
    required this.heightMm,
    this.rotationDegrees = 0,
    required this.scale,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.labelPanToMmDelta,
    required this.onMoved,
    required this.onBoundsChanged,
    required this.onRotationChanged,
    this.onDelete,
    this.isSelected = false,
    this.onTap,
    this.vectorChild,
  });

  final String imagePath;
  final Offset position;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
  final double scale;
  final double labelWidthMm;
  final double labelHeightMm;

  /// Pixels added to [position] so chips align with the white label when the
  /// interactive stack is asymmetrically padded (e.g. hit area on one side).
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final LabelPanMmDeltaCallback labelPanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final void Function(double xMm, double yMm, double widthMm, double heightMm)
      onBoundsChanged;
  final void Function(int rotationDegrees) onRotationChanged;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onTap;

  /// When set, drawn instead of [imagePath] (e.g. sex icon for `[*.sex]-img`).
  final Widget? vectorChild;

  @override
  State<_DraggableImageChip> createState() => _DraggableImageChipState();
}

class _DraggableImageChipState extends State<_DraggableImageChip> {
  static const double _handleVisual = 10;
  static const double _handleHit = 24;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  final GlobalKey _measureKey = GlobalKey();

  bool _moving = false;
  _ImageCorner? _resizeCorner;
  Rect? _resizeStart;
  Offset _resizeAccum = Offset.zero;

  /// During corner resize, parent template updates post-frame; local rect keeps UI in sync.
  Rect? _resizeLiveRect;

  double? _rotateStartFingerRad;
  int? _rotateStartElemDeg;
  int? _rotateLiveDeg;

  /// Last global position for this drag; [DragUpdateDetails.delta] is local.
  Offset? _imageMovePanLastGlobal;
  Offset? _resizePanLastGlobal;

  Offset? _imagePanOriginMm;
  Offset _imagePanAccumMm = Offset.zero;
  Offset? _imageDragLiveMm;
  int _imageMoveSession = 0;

  Offset _mmDeltaFromGlobalDrag(Offset globalPos, Offset globalDelta) {
    final s = _canvasScaleForMmMath(widget.scale);
    final fromStack = widget.labelPanToMmDelta(globalPos, globalDelta);
    if (fromStack != null) return fromStack;
    return Offset(globalDelta.dx / s, globalDelta.dy / s);
  }

  int get _effectiveRotationDeg => _rotateLiveDeg ?? widget.rotationDegrees;

  /// Drag in label mm → delta along image unrotated width/height (mm).
  Offset _labelDeltaToImageLocalMm(Offset dLabelMm) {
    final rad = _effectiveRotationDeg * math.pi / 180;
    final cosT = math.cos(rad);
    final sinT = math.sin(rad);
    final dlx = dLabelMm.dx * cosT - dLabelMm.dy * sinT;
    final dly = dLabelMm.dx * sinT + dLabelMm.dy * cosT;
    return Offset(dlx, dly);
  }

  void _onResizePanStart(DragStartDetails d, _ImageCorner c) {
    _beginResize(c);
    _resizePanLastGlobal = d.globalPosition;
  }

  void _beginResize(_ImageCorner c) {
    _resizeCorner = c;
    _resizeStart = Rect.fromLTWH(
      widget.position.dx,
      widget.position.dy,
      widget.widthMm,
      widget.heightMm,
    );
    _resizeAccum = Offset.zero;
  }

  void _onResizePanUpdate(DragUpdateDetails d) {
    if (_resizeCorner == null || _resizeStart == null) return;
    final last = _resizePanLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _resizePanLastGlobal = d.globalPosition;
    final dLabelMm = _mmDeltaFromGlobalDrag(d.globalPosition, gDelta);
    _resizeAccum += _labelDeltaToImageLocalMm(dLabelMm);
    final s = _resizeStart!;
    final a = _resizeAccum;
    late double x;
    late double y;
    late double rw;
    late double rh;
    switch (_resizeCorner!) {
      case _ImageCorner.br:
        x = s.left;
        y = s.top;
        rw = s.width + a.dx;
        rh = s.height + a.dy;
        break;
      case _ImageCorner.tr:
        x = s.left;
        y = s.top + a.dy;
        rw = s.width + a.dx;
        rh = s.height - a.dy;
        break;
      case _ImageCorner.bl:
        x = s.left + a.dx;
        y = s.top;
        rw = s.width - a.dx;
        rh = s.height + a.dy;
        break;
      case _ImageCorner.tl:
        x = s.left + a.dx;
        y = s.top + a.dy;
        rw = s.width - a.dx;
        rh = s.height - a.dy;
        break;
    }
    rw = rw.clamp(2.0, widget.labelWidthMm);
    rh = rh.clamp(2.0, widget.labelHeightMm);
    x = _clampMm(x, 0, math.max(0.0, widget.labelWidthMm - rw));
    y = _clampMm(y, 0, math.max(0.0, widget.labelHeightMm - rh));
    setState(() => _resizeLiveRect = Rect.fromLTWH(x, y, rw, rh));
    widget.onBoundsChanged(x, y, rw, rh);
  }

  void _endResize() {
    _resizeCorner = null;
    _resizeStart = null;
    _resizeAccum = Offset.zero;
    _resizePanLastGlobal = null;
    _resizeLiveRect = null;
  }

  void _beginRotate(DragStartDetails d) {
    _rotateStartElemDeg = widget.rotationDegrees;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final c =
        box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    _rotateStartFingerRad =
        math.atan2(d.globalPosition.dy - c.dy, d.globalPosition.dx - c.dx);
  }

  void _onRotatePanUpdate(DragUpdateDetails d) {
    if (_rotateStartFingerRad == null || _rotateStartElemDeg == null) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final c =
        box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    final cur =
        math.atan2(d.globalPosition.dy - c.dy, d.globalPosition.dx - c.dx);
    var delta = cur - _rotateStartFingerRad!;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    final deg = CustomImageElement.normalizeImageRotationDegrees(
      _rotateStartElemDeg! + delta * 180 / math.pi,
    );
    setState(() => _rotateLiveDeg = deg);
    widget.onRotationChanged(deg);
  }

  void _endRotate() {
    _rotateStartFingerRad = null;
    _rotateStartElemDeg = null;
    _rotateLiveDeg = null;
  }

  /// [innerLeft]/[innerTop] = top-left of the image rect inside the padded stack.
  Widget _cornerHandle(
    ColorScheme scheme,
    _ImageCorner corner, {
    required double innerLeft,
    required double innerTop,
    required double innerW,
    required double innerH,
  }) {
    final o = _handleHit / 2;
    late final double left;
    late final double top;
    switch (corner) {
      case _ImageCorner.tl:
        left = innerLeft - o;
        top = innerTop - o;
        break;
      case _ImageCorner.tr:
        left = innerLeft + innerW - o;
        top = innerTop - o;
        break;
      case _ImageCorner.bl:
        left = innerLeft - o;
        top = innerTop + innerH - o;
        break;
      case _ImageCorner.br:
        left = innerLeft + innerW - o;
        top = innerTop + innerH - o;
        break;
    }
    return Positioned(
      left: left,
      top: top,
      width: _handleHit,
      height: _handleHit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _onResizePanStart(d, corner),
        onPanUpdate: _onResizePanUpdate,
        onPanEnd: (_) => _deferSetState(_endResize),
        onPanCancel: () => _deferSetState(_endResize),
        child: Center(
          child: Container(
            width: _handleVisual,
            height: _handleVisual,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finishImageMoveGesture() {
    final session = _imageMoveSession;
    _imageMovePanLastGlobal = null;
    _imagePanOriginMm = null;
    _imagePanAccumMm = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _imageMoveSession) return;
      setState(() => _imageDragLiveMm = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final insetX = widget.canvasInsetXPx;
    final insetY = widget.canvasInsetYPx;
    final liveR = _resizeLiveRect;
    final posMm = liveR != null
        ? Offset(liveR.left, liveR.top)
        : (_imageDragLiveMm ?? widget.position);
    final effWmm = liveR?.width ?? widget.widthMm;
    final effHmm = liveR?.height ?? widget.heightMm;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final w = effWmm * widget.scale;
    final h = effHmm * widget.scale;
    final scheme = Theme.of(context).colorScheme;

    final borderColor = _moving
        ? scheme.primary
        : widget.isSelected
            ? scheme.primary
            : scheme.outline;

    // Padded outer stack so handles/rotate sit inside hit-test bounds (Flutter
    // does not hit-test children outside a tight w×h Stack).
    final padL = _handleHit / 2 + 6;
    final padR = _handleHit / 2 + 6;
    final padT = 52.0;
    final padB = _handleHit / 2 + 6;
    final outerW = w + padL + padR;
    final outerH = h + padT + padB;

    final rad = _effectiveRotationDeg * math.pi / 180;
    final pivotX = padL + w / 2;
    final pivotY = padT + h / 2;
    final rot = Matrix4.identity()
      ..translateByDouble(pivotX, pivotY, 0, 1)
      ..rotateZ(rad)
      ..translateByDouble(-pivotX, -pivotY, 0, 1);

    return Positioned(
      left: left - padL,
      top: top - padT,
      child: Transform(
        transform: rot,
        child: SizedBox(
          width: outerW,
          height: outerH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: padL,
                top: padT,
                width: w,
                height: h,
                child: GestureDetector(
                  key: _measureKey,
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onTap,
                  onPanStart: (d) {
                    _imageMoveSession++;
                    _imagePanOriginMm = widget.position;
                    _imagePanAccumMm = Offset.zero;
                    _imageDragLiveMm = null;
                    _deferSetState(() => _moving = true);
                    _imageMovePanLastGlobal = d.globalPosition;
                  },
                  onPanUpdate: (details) {
                    final last =
                        _imageMovePanLastGlobal ?? details.globalPosition;
                    final gDelta = details.globalPosition - last;
                    _imageMovePanLastGlobal = details.globalPosition;
                    final dMm =
                        _mmDeltaFromGlobalDrag(details.globalPosition, gDelta);
                    final origin = _imagePanOriginMm ?? widget.position;
                    _imagePanAccumMm += dMm;
                    final lr = _resizeLiveRect;
                    final w = lr?.width ?? widget.widthMm;
                    final h = lr?.height ?? widget.heightMm;
                    final maxX = math.max(0.0, widget.labelWidthMm - w);
                    final maxY = math.max(0.0, widget.labelHeightMm - h);
                    final rawX = origin.dx + _imagePanAccumMm.dx;
                    final rawY = origin.dy + _imagePanAccumMm.dy;
                    final cx = _clampMm(rawX, 0, maxX);
                    final cy = _clampMm(rawY, 0, maxY);
                    if (cx != rawX || cy != rawY) {
                      _imagePanOriginMm = Offset(cx, cy);
                      _imagePanAccumMm = Offset.zero;
                    }
                    final clamped = Offset(cx, cy);
                    setState(() => _imageDragLiveMm = clamped);
                    widget.onMoved(clamped);
                  },
                  onPanEnd: (_) {
                    _deferSetState(() => _moving = false);
                    _finishImageMoveGesture();
                  },
                  onPanCancel: () {
                    _deferSetState(() => _moving = false);
                    _finishImageMoveGesture();
                  },
                  child: AnimatedContainer(
                    duration: (_resizeCorner != null ||
                            _rotateStartFingerRad != null ||
                            _moving)
                        ? Duration.zero
                        : const Duration(milliseconds: 100),
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: (widget.isSelected || _moving) ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: scheme.surfaceContainerHighest,
                      boxShadow: _moving
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        if (widget.vectorChild != null)
                          Center(
                            child: IconTheme(
                              data: IconThemeData(
                                size: math.min(w, h) * 0.88,
                                color: scheme.onSurface,
                              ),
                              child: widget.vectorChild!,
                            ),
                          )
                        else if (isLabelImagePathUsable(widget.imagePath))
                          Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child:
                                  Icon(Icons.broken_image_outlined, size: 28),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 28),
                          ),
                        if (widget.vectorChild == null)
                          Positioned(
                            left: 2,
                            top: 2,
                            child: Icon(
                              Icons.drag_indicator,
                              size: 14,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.isSelected) ...[
                _cornerHandle(scheme, _ImageCorner.tl,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.tr,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.bl,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                _cornerHandle(scheme, _ImageCorner.br,
                    innerLeft: padL, innerTop: padT, innerW: w, innerH: h),
                Positioned(
                  left: padL + w / 2 - 20,
                  top: math.max(
                    0.0,
                    padT - 42 - (widget.onDelete != null ? 34.0 : 0.0),
                  ),
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onDelete != null) ...[
                        IconButton.filled(
                          tooltip: 'Remove image',
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.close, size: 13),
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.error,
                            foregroundColor: scheme.onError,
                            fixedSize: const Size(26, 26),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: _beginRotate,
                          onPanUpdate: _onRotatePanUpdate,
                          onPanEnd: (_) => _deferSetState(_endRotate),
                          onPanCancel: () => _deferSetState(_endRotate),
                          child: Tooltip(
                            message: 'Drag to rotate',
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(color: scheme.primary),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.rotate_right,
                                size: 18,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Draggable chip widget
// ---------------------------------------------------------------------------

class _DraggableChip extends StatefulWidget {
  const _DraggableChip({
    super.key,
    required this.label,
    this.actualText = '',
    required this.position,
    required this.fontSize,
    this.fontFamily = '',
    this.bold = false,
    this.italic = false,
    this.rotationDegrees = 0,
    required this.scale,
    required this.labelWidthMm,
    required this.labelHeightMm,
    this.canvasInsetXPx = 0,
    this.canvasInsetYPx = 0,
    required this.labelPanToMmDelta,
    required this.onMoved,
    this.isCustom = false,
    this.isSelected = false,
    this.isInlineEditing = false,
    this.onInlineEditingComplete,
    this.onInlineTextInsertBinding,
    this.onTap,
    this.onSelect,
  });

  final String label;

  /// Raw template text for custom chips (may be empty); ignored when not custom.
  final String actualText;
  final Offset position;
  final double fontSize;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final int rotationDegrees;
  final double scale;
  final double labelWidthMm;
  final double labelHeightMm;

  /// See [_DraggableImageChip.canvasInsetXPx].
  final double canvasInsetXPx;
  final double canvasInsetYPx;
  final LabelPanMmDeltaCallback labelPanToMmDelta;
  final void Function(Offset newPosMm) onMoved;
  final bool isCustom;
  final bool isSelected;
  final bool isInlineEditing;

  /// Called once when inline editing ends (focus lost or Enter); updates template text.
  final ValueChanged<String>? onInlineEditingComplete;

  /// Active while inline editing: non-null inserts at caret; null when edit ends.
  final ValueChanged<void Function(String)?>? onInlineTextInsertBinding;
  final VoidCallback? onTap;

  /// When pan wins over tap (slight movement), [onTap] may not run; parent uses
  /// this to select so the attributes bar appears immediately.
  final VoidCallback? onSelect;

  @override
  State<_DraggableChip> createState() => _DraggableChipState();
}

class _DraggableChipState extends State<_DraggableChip> {
  bool _dragging = false;
  TextEditingController? _inlineCtrl;
  FocusNode? _inlineFocus;
  bool _inlineEditCommitted = false;

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

  /// [DragUpdateDetails.delta] is local; track global positions for label mm.
  Offset? _labelDragLastGlobal;

  /// Parent template updates are deferred to post-frame; [widget.position] stays
  /// stale across multiple [onPanUpdate] calls, so we accumulate from drag start
  /// and paint from [_dragLiveMm] until the parent catches up.
  Offset? _panOriginMm;
  Offset _panAccumMm = Offset.zero;
  Offset? _dragLiveMm;
  int _labelDragSession = 0;

  Offset _mmDeltaForLabelPan(DragUpdateDetails d) {
    final last = _labelDragLastGlobal ?? d.globalPosition;
    final gDelta = d.globalPosition - last;
    _labelDragLastGlobal = d.globalPosition;
    final s = _canvasScaleForMmMath(widget.scale);
    final fromStack = widget.labelPanToMmDelta(d.globalPosition, gDelta);
    if (fromStack != null) return fromStack;
    return Offset(gDelta.dx / s, gDelta.dy / s);
  }

  Size _builtinChipSizePx() {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pt = TextPainter(
      text: TextSpan(
        text: '${widget.fontSize.toStringAsFixed(0)}pt',
        style: const TextStyle(fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const hPad = 10.0 * 2;
    const vPad = 8.0 * 2;
    final rowW = 16 + 4 + tp.width + 4 + pt.width;
    final rowH = math.max(16.0, math.max(tp.height, pt.height));
    return Size(hPad + rowW, vPad + rowH);
  }

  /// Unrotated hit target size in mm (axis-aligned box for clamping).
  Size _labelChipBoundsMm() {
    final scale = widget.scale;
    if (!widget.isCustom) {
      final px = _builtinChipSizePx();
      return Size(px.width / scale, px.height / scale);
    }
    final fontPx = widget.fontSize * scale / _kPdfPointsPerMm;
    final textStyle = customLabelCanvasTextStyle(
      fontFamilyRaw: widget.fontFamily,
      fontSize: fontPx,
      fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
    ).copyWith(color: Colors.black);
    final displayText =
        widget.actualText.isEmpty ? widget.label : widget.actualText;

    if (widget.isInlineEditing && _inlineCtrl != null) {
      final posMm = _dragLiveMm ?? widget.position;
      final handle = fontPx.clamp(18.0, 28.0);
      final fieldW = ((widget.labelWidthMm - posMm.dx) * scale - handle - 6)
          .clamp(48.0, 2000.0);
      final editTp = TextPainter(
        text: TextSpan(text: _inlineCtrl!.text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 6,
      )..layout(maxWidth: fieldW);
      final wPx = handle + fieldW;
      final hPx = math.max(handle + 4, editTp.height + 12);
      return Size(wPx / scale, hPx / scale);
    }

    final tp = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 6,
    )..layout(maxWidth: widget.labelWidthMm * scale);
    final handleSize = fontPx.clamp(20.0, 32.0);
    final wPx = handleSize + tp.width;
    final hPx = math.max(handleSize, tp.height);
    return Size(wPx / scale, hPx / scale);
  }

  void _onLabelPanStart(DragStartDetails d) {
    if (widget.isCustom && !widget.isSelected) {
      widget.onSelect?.call();
    }
    _labelDragSession++;
    _panOriginMm = widget.position;
    _panAccumMm = Offset.zero;
    _dragLiveMm = null;
    _deferSetState(() => _dragging = true);
    _labelDragLastGlobal = d.globalPosition;
  }

  void _finishLabelPanGesture() {
    final session = _labelDragSession;
    _labelDragLastGlobal = null;
    _panOriginMm = null;
    _panAccumMm = Offset.zero;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session != _labelDragSession) return;
      setState(() => _dragLiveMm = null);
    });
  }

  void _onLabelPanEnd() {
    _deferSetState(() => _dragging = false);
    _finishLabelPanGesture();
  }

  void _panMoveClampedToHitInset(DragUpdateDetails details) {
    final dMm = _mmDeltaForLabelPan(details);
    if (dMm.dx.isNaN ||
        dMm.dy.isNaN ||
        dMm.dx.isInfinite ||
        dMm.dy.isInfinite) {
      return;
    }
    final origin = _panOriginMm ?? widget.position;
    _panAccumMm += dMm;
    final bounds = _labelChipBoundsMm();
    final maxX = math.max(0.0, widget.labelWidthMm - bounds.width);
    final maxY = math.max(0.0, widget.labelHeightMm - bounds.height);
    final rawX = origin.dx + _panAccumMm.dx;
    final rawY = origin.dy + _panAccumMm.dy;
    final cx = _clampMm(rawX, 0, maxX);
    final cy = _clampMm(rawY, 0, maxY);
    if (cx != rawX || cy != rawY) {
      _panOriginMm = Offset(cx, cy);
      _panAccumMm = Offset.zero;
    }
    final clamped = Offset(cx, cy);
    setState(() => _dragLiveMm = clamped);
    widget.onMoved(clamped);
  }

  void _startInlineEditing() {
    _inlineEditCommitted = false;
    _inlineCtrl?.dispose();
    _inlineFocus?.removeListener(_onInlineFocusChange);
    _inlineFocus?.dispose();
    _inlineCtrl = TextEditingController(text: widget.actualText);
    _inlineFocus = FocusNode();
    _inlineFocus!.addListener(_onInlineFocusChange);
    widget.onInlineTextInsertBinding?.call(_pasteIntoInlineField);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isInlineEditing) return;
      _inlineFocus?.requestFocus();
      final t = _inlineCtrl?.text ?? '';
      _inlineCtrl?.selection = TextSelection.collapsed(offset: t.length);
    });
  }

  void _pasteIntoInlineField(String insertion) {
    final c = _inlineCtrl;
    if (c == null || !widget.isInlineEditing) return;
    final text = c.text;
    final sel = c.selection;
    var start = sel.isValid ? sel.start : text.length;
    var end = sel.isValid ? sel.end : text.length;
    if (start < 0 || start > text.length) start = text.length;
    if (end < 0 || end > text.length) end = text.length;
    if (start > end) {
      final t = start;
      start = end;
      end = t;
    }
    final newText = text.replaceRange(start, end, insertion);
    final newOffset = start + insertion.length;
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    _inlineFocus?.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isCustom && widget.isInlineEditing) {
      _startInlineEditing();
    }
    if (widget.isCustom) {
      _scheduleCanvasGoogleFontPrime();
    }
  }

  void _scheduleCanvasGoogleFontPrime() {
    if (!labelCanvasFontUsesGoogle(widget.fontFamily)) return;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadCanvasGoogleFontIfNeeded());
  }

  Future<void> _loadCanvasGoogleFontIfNeeded() async {
    if (!mounted || !widget.isCustom) return;
    try {
      await preloadGoogleFontForLabelCanvas(
        widget.fontFamily,
        widget.bold ? FontWeight.bold : FontWeight.normal,
        widget.italic ? FontStyle.italic : FontStyle.normal,
      );
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _DraggableChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCustom) return;
    if (oldWidget.fontFamily != widget.fontFamily ||
        oldWidget.bold != widget.bold ||
        oldWidget.italic != widget.italic) {
      _scheduleCanvasGoogleFontPrime();
    }
    if (widget.isInlineEditing && !oldWidget.isInlineEditing) {
      _startInlineEditing();
    } else if (!widget.isInlineEditing && oldWidget.isInlineEditing) {
      widget.onInlineTextInsertBinding?.call(null);
      if (!_inlineEditCommitted) {
        _commitInlineToParent();
      }
      _inlineEditCommitted = false;
      _inlineFocus?.removeListener(_onInlineFocusChange);
      _inlineFocus?.dispose();
      _inlineFocus = null;
      _inlineCtrl?.dispose();
      _inlineCtrl = null;
    } else if (widget.isInlineEditing &&
        _inlineCtrl != null &&
        widget.actualText != _inlineCtrl!.text &&
        !(_inlineFocus?.hasFocus ?? false)) {
      _inlineCtrl!.text = widget.actualText;
    }
  }

  void _onInlineFocusChange() {
    if (_inlineFocus == null || _inlineFocus!.hasFocus) return;
    _commitInlineToParent();
  }

  void _commitInlineToParent() {
    if (_inlineEditCommitted) return;
    _inlineEditCommitted = true;
    widget.onInlineEditingComplete?.call(_inlineCtrl?.text ?? '');
  }

  @override
  void dispose() {
    if (widget.isInlineEditing) {
      widget.onInlineTextInsertBinding?.call(null);
    }
    _inlineFocus?.removeListener(_onInlineFocusChange);
    _inlineFocus?.dispose();
    _inlineCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insetX = widget.canvasInsetXPx;
    final insetY = widget.canvasInsetYPx;
    final posMm = _dragLiveMm ?? widget.position;
    final left = posMm.dx * widget.scale + insetX;
    final top = posMm.dy * widget.scale + insetY;
    final scheme = Theme.of(context).colorScheme;

    if (widget.isCustom) {
      // Match PDF: pw.Text at (xMm,yMm), fontSize in pt, rotateZ about top-left.
      final fontPx = widget.fontSize * widget.scale / _kPdfPointsPerMm;
      final textStyle = customLabelCanvasTextStyle(
        fontFamilyRaw: widget.fontFamily,
        fontSize: fontPx,
        fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
        fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
      ).copyWith(color: Colors.black);

      if (widget.isInlineEditing &&
          _inlineCtrl != null &&
          _inlineFocus != null) {
        final handle = fontPx.clamp(18.0, 28.0);
        final fieldW =
            ((widget.labelWidthMm - posMm.dx) * widget.scale - handle - 6)
                .clamp(48.0, 2000.0);
        final editor = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onLabelPanStart,
              onPanUpdate: _panMoveClampedToHitInset,
              onPanEnd: (_) => _onLabelPanEnd(),
              onPanCancel: _onLabelPanEnd,
              child: SizedBox(
                width: handle,
                height: handle + 4,
                child: Icon(
                  Icons.drag_indicator,
                  size: handle,
                  color: scheme.primary,
                ),
              ),
            ),
            SizedBox(
              width: fieldW,
              child: TextField(
                controller: _inlineCtrl,
                focusNode: _inlineFocus,
                autofocus: true,
                style: textStyle,
                maxLines: 6,
                minLines: 1,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                ),
                onSubmitted: (_) => _inlineFocus?.unfocus(),
              ),
            ),
          ],
        );
        return Positioned(
          left: left,
          top: top,
          child: Transform.rotate(
            angle: widget.rotationDegrees * math.pi / 180,
            alignment: Alignment.topLeft,
            child: editor,
          ),
        );
      }

      final text = Text(
        widget.label,
        style: textStyle,
      );
      final handleSize = fontPx.clamp(20.0, 32.0);
      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: widget.rotationDegrees * math.pi / 180,
          alignment: Alignment.topLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onPanStart: _onLabelPanStart,
            onPanUpdate: _panMoveClampedToHitInset,
            onPanEnd: (_) => _onLabelPanEnd(),
            onPanCancel: _onLabelPanEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: handleSize,
                  height: handleSize,
                  child: Center(
                    child: Icon(
                      Icons.drag_indicator,
                      size: handleSize * 0.65,
                      color: scheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Container(
                  foregroundDecoration: (widget.isSelected || _dragging)
                      ? BoxDecoration(
                          border: Border.all(color: scheme.primary, width: 2),
                        )
                      : null,
                  child: text,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Color bgColor;
    final Color fgColor;
    final Color borderColor;
    if (_dragging) {
      bgColor = scheme.primaryContainer;
      fgColor = Colors.black;
      borderColor = scheme.primary;
    } else if (widget.isSelected) {
      bgColor = Colors.amber.shade50;
      fgColor = Colors.black;
      borderColor = scheme.primary;
    } else {
      bgColor = Colors.grey.shade200;
      fgColor = Colors.black87;
      borderColor = Colors.grey.shade500;
    }

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: (widget.isSelected || _dragging) ? 2.0 : 1.0,
        ),
        boxShadow: _dragging
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.drag_indicator, size: 16, color: fgColor),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fgColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.fontSize.toStringAsFixed(0)}pt',
            style:
                TextStyle(fontSize: 9, color: fgColor.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: widget.rotationDegrees * math.pi / 180,
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onPanStart: _onLabelPanStart,
          onPanUpdate: _panMoveClampedToHitInset,
          onPanEnd: (_) => _onLabelPanEnd(),
          onPanCancel: _onLabelPanEnd,
          child: chip,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SyncedFontSizeField extends StatefulWidget {
  const _SyncedFontSizeField({
    super.key,
    required this.fontSizePt,
    required this.onValidSize,
  });

  final double fontSizePt;
  final ValueChanged<double> onValidSize;

  @override
  State<_SyncedFontSizeField> createState() => _SyncedFontSizeFieldState();
}

class _SyncedFontSizeFieldState extends State<_SyncedFontSizeField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.fontSizePt.toStringAsFixed(1));
    _focus = FocusNode();
    _controller.addListener(_onEdit);
  }

  void _onEdit() {
    final p = double.tryParse(_controller.text.trim());
    if (p != null && p >= 4 && p <= 72) {
      widget.onValidSize(p);
    }
  }

  @override
  void didUpdateWidget(covariant _SyncedFontSizeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fontSizePt != widget.fontSizePt) {
      final next = widget.fontSizePt.toStringAsFixed(1);
      if (_controller.text != next) {
        _controller.removeListener(_onEdit);
        _controller.text = next;
        _controller.addListener(_onEdit);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onEdit);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      style: const TextStyle(fontSize: 14),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

// ---------------------------------------------------------------------------

/// Rounded frame with a solid vertical rail on the **right** (end drawer).
class _EndSidebarPanelIcon extends StatelessWidget {
  const _EndSidebarPanelIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EndSidebarPanelIconPainter(color: color),
    );
  }
}

class _EndSidebarPanelIconPainter extends CustomPainter {
  _EndSidebarPanelIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final m = w * 0.1;
    final radius = w * 0.12;
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m),
      Radius.circular(radius),
    );
    final stroke = (w * 0.09).clamp(1.5, 2.5);
    canvas.drawRRect(
      outer,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final innerPad = w * 0.06;
    final barW = w * 0.24;
    final barRight = w - m - innerPad;
    final barLeft = barRight - barW;
    final barTop = m + innerPad;
    final barBottom = h - m - innerPad;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      Radius.circular(stroke * 0.35),
    );
    canvas.drawRRect(bar, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _EndSidebarPanelIconPainter old) =>
      old.color != color;
}

// ---------------------------------------------------------------------------

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.labelWidthMm,
    required this.labelHeightMm,
    required this.scale,
  });

  final double labelWidthMm;
  final double labelHeightMm;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    final thickPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    const smallStep = 1.0;
    const bigStep = 5.0;

    for (double x = 0; x <= labelWidthMm; x += smallStep) {
      final px = x * scale;
      final isMajor = (x % bigStep) < 0.01;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height),
          isMajor ? thickPaint : thinPaint);
    }
    for (double y = 0; y <= labelHeightMm; y += smallStep) {
      final py = y * scale;
      final isMajor = (y % bigStep) < 0.01;
      canvas.drawLine(Offset(0, py), Offset(size.width, py),
          isMajor ? thickPaint : thinPaint);
    }

    final textStyle = TextStyle(color: Colors.grey.shade500, fontSize: 9);
    for (double x = 0; x <= labelWidthMm; x += 10) {
      final tp = TextPainter(
        text: TextSpan(text: '${x.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x * scale + 2, 2));
    }
    for (double y = 10; y <= labelHeightMm; y += 10) {
      final tp = TextPainter(
        text: TextSpan(text: '${y.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y * scale + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.scale != scale ||
      old.labelWidthMm != labelWidthMm ||
      old.labelHeightMm != labelHeightMm;
}
