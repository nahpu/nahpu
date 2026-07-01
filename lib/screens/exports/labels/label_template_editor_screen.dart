import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nahpu/screens/exports/labels/label_border_sheet.dart';
import 'package:nahpu/screens/exports/labels/label_size_selector.dart';
import 'package:nahpu/screens/exports/labels/label_template_fonts.dart';
import 'package:nahpu/screens/exports/labels/label_template_model.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/label_template_editor_service.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/services/label_logo_service.dart';
import 'package:nahpu/screens/exports/labels/components/label_canvas_editor.dart';
import 'package:nahpu/screens/exports/labels/components/label_element_properties_panel.dart';
import 'package:nahpu/screens/exports/labels/components/text_element_editor.dart';

import 'package:nahpu/screens/exports/labels/components/front_back_page_pickers.dart';
import 'package:nahpu/screens/exports/labels/components/zoom_controls.dart';
import 'package:nahpu/screens/exports/labels/components/mirror_toggle_button.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/screens/exports/labels/label_preview_specimen_selection.dart';
import 'package:path/path.dart' as path;

/// PDF points per mm (72 / 25.4); keep in sync with `labelPdfMmToPt`.

/// Pixels → mm along label axes (mirror, scroll, nested transforms).
/// [globalDelta] must be in **global** logical pixels (not [DragUpdateDetails.delta],
/// which is local to the gesture target and wrong under [Transform.rotate]).
typedef LabelPanMmDeltaCallback = Offset? Function(
    Offset globalPosition, Offset globalDelta);

/// Logical px → mm along label axes; avoids div-by-zero before layout settles.

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
  final LabelTemplateEditorService _editorService =
      LabelTemplateEditorService();

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
  int _customIdCounter = 0;
  int _imageIdCounter = 0;

  /// Bumps when the logo folder gains a file so [FutureBuilder] strips reload.
  int _logoLibraryEpoch = 0;

  String? _selectedSpecimenUuid;

  /// First specimen’s `[field]` map for canvas preview (sex icons, etc.).
  Map<String, String> _editorLabelFieldPreview = {};

  final bool _isPreviewMode = true;
  final String _fieldDisplayOption = 'short';

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

  CustomLineElement? _pendingLineTemplate;
  bool? _pendingLineTemplatePage1;
  bool _lineTemplateFlushScheduled = false;

  void _scheduleTemplateLineUpdate(bool page1, CustomLineElement element) {
    _pendingLineTemplate = element;
    _pendingLineTemplatePage1 = page1;
    if (_lineTemplateFlushScheduled) return;
    _lineTemplateFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lineTemplateFlushScheduled = false;
      if (!mounted) return;
      final el = _pendingLineTemplate;
      final p = _pendingLineTemplatePage1;
      _pendingLineTemplate = null;
      _pendingLineTemplatePage1 = null;
      if (el == null || p == null) return;
      setState(() {
        if (p) {
          _template = _template.copyWith(
            page1: _template.page1.withCustomLine(el),
          );
        } else {
          _template = _template.copyWith(
            page2: _template.page2.withCustomLine(el),
          );
        }
      });
    });
  }

  CustomShapeElement? _pendingShapeTemplate;
  bool? _pendingShapeTemplatePage1;
  bool _shapeTemplateFlushScheduled = false;

  void _scheduleTemplateShapeUpdate(bool page1, CustomShapeElement element) {
    _pendingShapeTemplate = element;
    _pendingShapeTemplatePage1 = page1;
    if (_shapeTemplateFlushScheduled) return;
    _shapeTemplateFlushScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shapeTemplateFlushScheduled = false;
      if (!mounted) return;
      final el = _pendingShapeTemplate;
      final p = _pendingShapeTemplatePage1;
      _pendingShapeTemplate = null;
      _pendingShapeTemplatePage1 = null;
      if (el == null || p == null) return;
      setState(() {
        if (p) {
          _template = _template.copyWith(
            page1: _template.page1.withCustomShape(el),
          );
        } else {
          _template = _template.copyWith(
            page2: _template.page2.withCustomShape(el),
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
      final firstSpecimen = list.first;
      final m = await fieldValuesForSpecimen(db, firstSpecimen, ref);
      if (mounted) {
        setState(() {
          _selectedSpecimenUuid = firstSpecimen.uuid;
          _editorLabelFieldPreview = m;
        });
      }
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Editor'),
        actions: [
          IconButton(
            onPressed: _promptSaveTemplate,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save template',
          ),
          PopupMenuButton<String>(
            tooltip: 'Template Options',
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              if (action == 'import') {
                _importTemplate();
              } else if (action == 'export') {
                _exportTemplate();
              } else if (action == 'delete') {
                _confirmDeleteTemplate();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: 'import', child: Text('Import template')),
              const PopupMenuItem(
                  value: 'export', child: Text('Export template')),
              if (_canDeleteSavedTemplate)
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete template',
                      style: TextStyle(color: scheme.error)),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: isMobile
            ? EdgeInsets.only(
                left: viewPadding.left,
                right: viewPadding.right,
                bottom: viewPadding.bottom,
              )
            : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(50),
                  ),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownMenu<String>(
                            initialSelection:
                                _savedNames.contains(_template.name)
                                    ? _template.name
                                    : null,
                            label: const Text('Preset label'),
                            inputDecorationTheme: const InputDecorationTheme(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            dropdownMenuEntries: [
                              for (final n in _savedNames)
                                DropdownMenuEntry(value: n, label: n),
                            ],
                            onSelected: (value) {
                              if (value != null) {
                                _loadTemplate(value);
                              }
                            },
                          ),
                        ),
                        SegmentedButton<bool>(
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
                            });
                            await _labelSettings.setDuplex(duplex);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FrontBackPagePickers(
                            isDuplex: _isDuplex,
                            isPage1: _isPage1,
                            mirrorFront: _mirrorFront,
                            mirrorBack: _mirrorBack,
                            onPageChanged: (idx) {
                              _tabController.animateTo(idx);
                              _deferSetState(() {
                                _selectedElement = null;
                              });
                            },
                          ),
                          if (_isDuplex) const SizedBox(width: 8),
                          if (_isDuplex) ...[
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 4,
                              endIndent: 4,
                              color: scheme.outlineVariant,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            'Label size:',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: scheme.onSurface,
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
                          const SizedBox(width: 16),
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
                          IconButton.filledTonal(
                            onPressed: () => _addCustomLine(_isPage1),
                            icon: const Icon(Icons.horizontal_rule),
                            tooltip: 'Add line',
                          ),
                          const SizedBox(width: 4),
                          IconButton.filledTonal(
                            onPressed: () => _addCustomShape(_isPage1),
                            icon: const Icon(Icons.crop_square),
                            tooltip: 'Add shape',
                          ),
                          const SizedBox(width: 16),
                          MirrorToggleButton(
                            isMirrorActive:
                                _isPage1 ? _mirrorFront : _mirrorBack,
                            sideLabel: _isDuplex
                                ? (_isPage1 ? 'Front' : 'Back')
                                : 'Front',
                            onToggle: () async {
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
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            tooltip: 'Label border',
                            style: IconButton.styleFrom(
                              foregroundColor: _labelBorderPanelOpen
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              backgroundColor: _labelBorderPanelOpen
                                  ? scheme.primaryContainer
                                      .withValues(alpha: 0.45)
                                  : null,
                            ),
                            onPressed: () => _deferSetState(() {
                              _labelBorderPanelOpen = !_labelBorderPanelOpen;
                              if (_labelBorderPanelOpen) {
                                _labelBorderPanelSession++;
                              }
                            }),
                            icon: const Icon(Icons.border_outer, size: 22),
                          ),
                          IconButton(
                            tooltip: _showGrid ? 'Hide grid' : 'Show grid',
                            style: IconButton.styleFrom(
                              foregroundColor: scheme.onSurfaceVariant,
                            ),
                            onPressed: () =>
                                _deferSetState(() => _showGrid = !_showGrid),
                            icon: Icon(
                              _showGrid ? Icons.grid_on : Icons.grid_off,
                              size: 22,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Select specimen for text preview',
                            style: IconButton.styleFrom(
                              foregroundColor: scheme.onSurfaceVariant,
                            ),
                            onPressed: _selectSpecimenForPreview,
                            icon: const Icon(
                              Icons.manage_search,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: _selectedElement != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: LabelElementPropertiesPanel(
                        selectedElement: _selectedElement!,
                        page1: _isPage1,
                        template: _template,
                        onUpdateCustomText: _updateCustomText,
                        onDeleteCustomText: _deleteCustomText,
                        onUpdateCustomImage: (page1, el) =>
                            _scheduleTemplateImageUpdate(page1, el),
                        onDeleteCustomImage: _removeCustomImage,
                        onUpdateCustomLine: _updateCustomLine,
                        onDeleteCustomLine: _removeCustomLine,
                        onUpdateCustomShape: _updateCustomShape,
                        onDeleteCustomShape: _removeCustomShape,
                        onDismiss: () => _deferSetState(() {
                          _selectedElement = null;
                        }),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: _isDuplex
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              LabelCanvasEditor(
                                page1: true,
                                template: _template,
                                labelWidthMm: _labelWidthMm,
                                labelHeightMm: _labelHeightMm,
                                zoom: _zoom,
                                showGrid: _showGrid,
                                mirrorFront: _mirrorFront,
                                mirrorBack: _mirrorBack,
                                isPreviewMode: _isPreviewMode,
                                editorLabelFieldPreview:
                                    _editorLabelFieldPreview,
                                selectedElement: _selectedElement,
                                labelStackKey: _labelStackKeyPage1,
                                labelPanGlobalDeltaToMm:
                                    _labelPanGlobalDeltaToMm,
                                fieldDisplayOption: _fieldDisplayOption,
                                onClearSelection: () => _deferSetState(() {
                                  _selectedElement = null;
                                }),
                                onSelectElement: (id) => _deferSetState(() {
                                  _selectedElement = id;
                                }),
                                onStartInlineEditing: (id) {
                                  _deferSetState(() {
                                    _selectedElement = id;
                                  });
                                  _showTextEditDialog(id);
                                },
                                onScheduleTemplateImageUpdate: (element) =>
                                    _scheduleTemplateImageUpdate(true, element),
                                onRemoveCustomImage: (id) =>
                                    _removeCustomImage(true, id),
                                onScheduleTemplateTextPositionUpdate:
                                    (element) =>
                                        _scheduleTemplateTextPositionUpdate(
                                            true, element),
                                onScheduleTemplateLineUpdate: (element) =>
                                    _scheduleTemplateLineUpdate(true, element),
                                onRemoveCustomLine: (id) =>
                                    _removeCustomLine(true, id),
                                onScheduleTemplateShapeUpdate: (element) =>
                                    _scheduleTemplateShapeUpdate(true, element),
                                onRemoveCustomShape: (id) =>
                                    _removeCustomShape(true, id),
                              ),
                              LabelCanvasEditor(
                                page1: false,
                                template: _template,
                                labelWidthMm: _labelWidthMm,
                                labelHeightMm: _labelHeightMm,
                                zoom: _zoom,
                                showGrid: _showGrid,
                                mirrorFront: _mirrorFront,
                                mirrorBack: _mirrorBack,
                                isPreviewMode: _isPreviewMode,
                                editorLabelFieldPreview:
                                    _editorLabelFieldPreview,
                                selectedElement: _selectedElement,
                                labelStackKey: _labelStackKeyPage2,
                                labelPanGlobalDeltaToMm:
                                    _labelPanGlobalDeltaToMm,
                                fieldDisplayOption: _fieldDisplayOption,
                                onClearSelection: () => _deferSetState(() {
                                  _selectedElement = null;
                                }),
                                onSelectElement: (id) => _deferSetState(() {
                                  _selectedElement = id;
                                }),
                                onStartInlineEditing: (id) {
                                  _deferSetState(() {
                                    _selectedElement = id;
                                  });
                                  _showTextEditDialog(id);
                                },
                                onScheduleTemplateImageUpdate: (element) =>
                                    _scheduleTemplateImageUpdate(
                                        false, element),
                                onRemoveCustomImage: (id) =>
                                    _removeCustomImage(false, id),
                                onScheduleTemplateTextPositionUpdate:
                                    (element) =>
                                        _scheduleTemplateTextPositionUpdate(
                                            false, element),
                                onScheduleTemplateLineUpdate: (element) =>
                                    _scheduleTemplateLineUpdate(false, element),
                                onRemoveCustomLine: (id) =>
                                    _removeCustomLine(false, id),
                                onScheduleTemplateShapeUpdate: (element) =>
                                    _scheduleTemplateShapeUpdate(
                                        false, element),
                                onRemoveCustomShape: (id) =>
                                    _removeCustomShape(false, id),
                              ),
                            ],
                          )
                        : LabelCanvasEditor(
                            page1: true,
                            template: _template,
                            labelWidthMm: _labelWidthMm,
                            labelHeightMm: _labelHeightMm,
                            zoom: _zoom,
                            showGrid: _showGrid,
                            mirrorFront: _mirrorFront,
                            mirrorBack: _mirrorBack,
                            isPreviewMode: _isPreviewMode,
                            editorLabelFieldPreview: _editorLabelFieldPreview,
                            selectedElement: _selectedElement,
                            labelStackKey: _labelStackKeyPage1,
                            labelPanGlobalDeltaToMm: _labelPanGlobalDeltaToMm,
                            fieldDisplayOption: _fieldDisplayOption,
                            onClearSelection: () => _deferSetState(() {
                              _selectedElement = null;
                            }),
                            onSelectElement: (id) => _deferSetState(() {
                              _selectedElement = id;
                            }),
                            onStartInlineEditing: (id) {
                              _deferSetState(() {
                                _selectedElement = id;
                              });
                              _showTextEditDialog(id);
                            },
                            onScheduleTemplateImageUpdate: (element) =>
                                _scheduleTemplateImageUpdate(true, element),
                            onRemoveCustomImage: (id) =>
                                _removeCustomImage(true, id),
                            onScheduleTemplateTextPositionUpdate: (element) =>
                                _scheduleTemplateTextPositionUpdate(
                                    true, element),
                            onScheduleTemplateLineUpdate: (element) =>
                                _scheduleTemplateLineUpdate(true, element),
                            onRemoveCustomLine: (id) =>
                                _removeCustomLine(true, id),
                            onScheduleTemplateShapeUpdate: (element) =>
                                _scheduleTemplateShapeUpdate(true, element),
                            onRemoveCustomShape: (id) =>
                                _removeCustomShape(true, id),
                          ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: ZoomControls(
                      zoom: _zoom,
                      onZoomChanged: (z) => _deferSetState(() => _zoom = z),
                    ),
                  ),
                ],
              ),
            ),
            if (_labelBorderPanelOpen) _buildLabelBorderPanel(),
          ],
        ),
      ),
    );
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
    });
  }

  void _addCustomLine(bool page1) {
    final id = 'line_$_customIdCounter';
    _customIdCounter++;
    final element = CustomLineElement(
      id: id,
      xMm: 5,
      yMm: 5,
      lengthMm: 10,
    );
    final sel = 'line:${page1 ? '1' : '2'}:$id';
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomLine(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomLine(element));
      }
      _selectedElement = sel;
    });
  }

  void _addCustomShape(bool page1) {
    final id = 'shape_$_customIdCounter';
    _customIdCounter++;
    final element = CustomShapeElement(
      id: id,
      xMm: 5,
      yMm: 5,
      widthMm: 10,
      heightMm: 10,
      shapeType: 'rect',
    );
    final sel = 'shape:${page1 ? '1' : '2'}:$id';
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomShape(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomShape(element));
      }
      _selectedElement = sel;
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

  CustomTextElement? _findCustomText(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    try {
      return page.customTexts.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void _showTextEditDialog(String sel) {
    final parts = sel.split(':');
    if (parts.length != 3) return;
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ct = _findCustomText(page1, id);
    if (ct == null) return;

    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    if (isLargeScreen) {
      showDialog(
        context: context,
        builder: (context) => TextElementEditorDialog(
          initialText: ct.text,
          onSave: (newText) {
            _updateCustomText(
              page1,
              ct.copyWith(text: newText),
            );
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => TextElementEditorBottomSheet(
          initialText: ct.text,
          onSave: (newText) {
            _updateCustomText(
              page1,
              ct.copyWith(text: newText),
            );
          },
        ),
      );
    }
  }

  void _updateCustomLine(bool page1, CustomLineElement element) {
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomLine(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomLine(element));
      }
    });
  }

  void _updateCustomShape(bool page1, CustomShapeElement element) {
    setState(() {
      if (page1) {
        _template =
            _template.copyWith(page1: _template.page1.withCustomShape(element));
      } else {
        _template =
            _template.copyWith(page2: _template.page2.withCustomShape(element));
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
      }
    });
  }

  void _removeCustomLine(bool page1, String id) {
    _deferSetState(() {
      if (page1) {
        _template = _template.copyWith(
          page1: _template.page1.withoutCustomLine(id),
        );
      } else {
        _template = _template.copyWith(
          page2: _template.page2.withoutCustomLine(id),
        );
      }
      if (_selectedElement == 'line:${page1 ? '1' : '2'}:$id') {
        _selectedElement = null;
      }
    });
  }

  void _removeCustomShape(bool page1, String id) {
    _deferSetState(() {
      if (page1) {
        _template = _template.copyWith(
          page1: _template.page1.withoutCustomShape(id),
        );
      } else {
        _template = _template.copyWith(
          page2: _template.page2.withoutCustomShape(id),
        );
      }
      if (_selectedElement == 'shape:${page1 ? '1' : '2'}:$id') {
        _selectedElement = null;
      }
    });
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
      }
    });
  }

  /// Picks an image file and copies it into the label logos folder; returns
  /// the stored path or null.
  Future<String?> _copyPickedImageToLogos() async {
    final added = await _editorService.copyPickedImageToLogos();
    if (added != null && mounted) {
      setState(() => _logoLibraryEpoch++);
    }
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
    final name =
        await _editorService.promptSaveTemplate(context, _template.name);
    if (name == null || !mounted) return;
    await _saveTemplateWithName(name);
  }

  /// When import would overwrite an existing saved template, user picks a new unique name.
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
    final merged = _templateWithCurrentPrintOptions();
    await _editorService.exportTemplate(context, merged);
  }

  Future<void> _importTemplate() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
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
          final newName = await _editorService.promptImportNewName(
            context,
            name,
            taken,
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
    final ok = await _editorService.confirmDeleteTemplate(context, name);
    if (!ok || !mounted) return;
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
      _syncDuplexTabIndex();
    });
  }

  /// Mirror for the side currently being edited (front tab or single-sided).

  /// Portrait rows 3+4: page/label on one line, tool buttons on next.

  /// Landscape: page/label + tool buttons merged into one row.

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

  Future<void> _selectSpecimenForPreview() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => LabelPreviewSpecimenSelectionScreen(
          selectedUuid: _selectedSpecimenUuid,
        ),
      ),
    );

    if (result != null && mounted) {
      final db = ref.read(databaseProvider);
      try {
        final s = await SpecimenServices(ref: ref).getSpecimen(result);
        final m = await fieldValuesForSpecimen(db, s, ref);
        setState(() {
          _selectedSpecimenUuid = result;
          _editorLabelFieldPreview = m;
        });
      } catch (_) {}
    }
  }
}
