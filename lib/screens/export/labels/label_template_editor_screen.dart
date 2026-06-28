import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nahpu/screens/export/labels/label_border_sheet.dart';
import 'package:nahpu/screens/export/labels/label_canvas_stack.dart';
import 'package:nahpu/screens/export/labels/label_outline.dart';
import 'package:nahpu/screens/export/labels/label_size_selector.dart';
import 'package:nahpu/screens/export/labels/label_template_fonts.dart';
import 'package:nahpu/screens/export/labels/label_gender_icon.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/label_template_editor_service.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/services/label_logo_service.dart';
import 'package:nahpu/screens/export/labels/components/draggable_image_chip.dart';
import 'package:nahpu/screens/export/labels/components/draggable_line_chip.dart';
import 'package:nahpu/screens/export/labels/components/draggable_shape_chip.dart';
import 'package:nahpu/screens/export/labels/components/draggable_chip.dart';
import 'package:nahpu/screens/export/labels/components/synced_font_size_field.dart';
import 'package:nahpu/screens/export/labels/components/grid_painter.dart';
import 'package:nahpu/screens/export/labels/components/available_fields_panel.dart';
import 'package:nahpu/screens/export/labels/components/front_back_page_pickers.dart';
import 'package:nahpu/screens/export/labels/components/zoom_controls.dart';
import 'package:nahpu/screens/export/labels/components/mirror_toggle_button.dart';
import 'package:nahpu/screens/export/labels/components/fields_panel_toggle_button.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:path/path.dart' as path;

/// PDF points per mm (72 / 25.4); keep in sync with `labelPdfMmToPt`.

/// Invisible margin around the label so resize/rotate controls that paint outside
/// the white rect still receive hit tests (tight [SizedBox] would drop them).
const double _kLabelCanvasHitPadPx = 72.0;

/// Pixels → mm along label axes (mirror, scroll, nested transforms).
/// [globalDelta] must be in **global** logical pixels (not [DragUpdateDetails.delta],
/// which is local to the gesture target and wrong under [Transform.rotate]).
typedef LabelPanMmDeltaCallback = Offset? Function(
    Offset globalPosition, Offset globalDelta);

/// Logical px → mm along label axes; avoids div-by-zero before layout settles.

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
  String? _inlineCanvasCustomKey;

  int _customIdCounter = 0;
  int _imageIdCounter = 0;

  /// Bumps when the logo folder gains a file so [FutureBuilder] strips reload.
  int _logoLibraryEpoch = 0;

  /// First specimen’s `[field]` map for canvas preview (sex icons, etc.).
  Map<String, String> _editorLabelFieldPreview = {};

  bool _fieldsPanelExpanded = false;
  bool _isPreviewMode = true;


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
      final m = await fieldValuesForSpecimen(db, list.first, ref);
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
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
                  Material(
                    elevation: 1,
                    surfaceTintColor: scheme.surfaceTint,
                    color: scheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownMenu<String>(
                                initialSelection: _savedNames.contains(_template.name)
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
                              const SizedBox(width: 16),
                              SegmentedButton<bool>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(
                                      value: false, label: Text('1 sided')),
                                  ButtonSegment(
                                      value: true, label: Text('2 sided')),
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
                                      _inlineCanvasCustomKey = null;
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
                                  onPressed: () =>
                                      _showAddImageDialog(_isPage1),
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
                                const SizedBox(width: 4),
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
                                const SizedBox(width: 4),
                                IconButton.filledTonal(
                                  onPressed: () {
                                    _deferSetState(() => _isPreviewMode = !_isPreviewMode);
                                  },
                                  icon: Icon(_isPreviewMode ? Icons.edit_outlined : Icons.visibility_outlined),
                                  tooltip: _isPreviewMode ? 'Edit' : 'Preview',
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
                                    _labelBorderPanelOpen =
                                        !_labelBorderPanelOpen;
                                    if (_labelBorderPanelOpen) {
                                      _labelBorderPanelSession++;
                                    }
                                  }),
                                  icon:
                                      const Icon(Icons.border_outer, size: 22),
                                ),
                                IconButton(
                                  tooltip:
                                      _showGrid ? 'Hide grid' : 'Show grid',
                                  style: IconButton.styleFrom(
                                    foregroundColor: scheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => _deferSetState(
                                      () => _showGrid = !_showGrid),
                                  icon: Icon(
                                    _showGrid ? Icons.grid_on : Icons.grid_off,
                                    size: 22,
                                  ),
                                ),
                                FieldsPanelToggleButton(
                                  isExpanded: _fieldsPanelExpanded,
                                  onToggle: () => _deferSetState(() =>
                                      _fieldsPanelExpanded =
                                          !_fieldsPanelExpanded),
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
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildElementPanel(_selectedElement!, inToolbar: true),
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
                                    _buildCanvas(page1: true),
                                    _buildCanvas(page1: false),
                                  ],
                                )
                              : _buildCanvas(page1: true),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: ZoomControls(
                            zoom: _zoom,
                            onZoomChanged: (z) =>
                                _deferSetState(() => _zoom = z),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_labelBorderPanelOpen) _buildLabelBorderPanel(),
                ],
              ),
            ),
          ),
          AvailableFieldsPanel(
            isExpanded: _fieldsPanelExpanded,
            onAddField: (label) {
              final paste = _inlineCustomTextPaste;
              if (paste != null) {
                paste(label);
              } else {
                _addCustomTextWithLabel(_isPage1, label);
              }
            },
          ),
        ],
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
      _inlineCanvasCustomKey = sel;
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
      _inlineCanvasCustomKey = sel;
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
        _inlineCanvasCustomKey = null;
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

  CustomImageElement? _findCustomImage(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customImages) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomLineElement? _findCustomLine(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customLines) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomShapeElement? _findCustomShape(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customShapes) {
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
      _inlineCanvasCustomKey = null;
      _syncDuplexTabIndex();
    });
  }

  /// Mirror for the side currently being edited (front tab or single-sided).



  /// Portrait rows 3+4: page/label on one line, tool buttons on next.

  /// Landscape: page/label + tool buttons merged into one row.

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
                                            painter: GridPainter(
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
                          ...(() {
                            final allElements = <dynamic>[
                              ...page.customImages,
                              ...page.customTexts,
                              ...page.customLines,
                              ...page.customShapes,
                            ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));

                            return allElements.map<Widget>((element) {
                              if (element is CustomImageElement) {
                                return DraggableImageChip(
                                  key: ValueKey('p${page1 ? '1' : '2'}_img_${element.id}'),
                                  imagePath: element.imagePath,
                                  position: Offset(element.xMm, element.yMm),
                                  widthMm: element.widthMm,
                                  heightMm: element.heightMm,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: _labelWidthMm,
                                  labelHeightMm: _labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: _selectedElement == 'image:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => _deferSetState(() {
                                    _selectedElement = 'image:${page1 ? '1' : '2'}:${element.id}';
                                    _inlineCanvasCustomKey = null;
                                  }),
                                  onMoved: (pos) {
                                    final maxX = math.max(0.0, _labelWidthMm - element.widthMm);
                                    final maxY = math.max(0.0, _labelHeightMm - element.heightMm);
                                    _scheduleTemplateImageUpdate(
                                      page1,
                                      element.copyWith(
                                        xMm: _clampMm(pos.dx, 0, maxX),
                                        yMm: _clampMm(pos.dy, 0, maxY),
                                      ),
                                    );
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    _scheduleTemplateImageUpdate(
                                      page1,
                                      element.copyWith(
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
                                      element.copyWith(rotationDegrees: deg),
                                    );
                                  },
                                  onDelete: () => _removeCustomImage(page1, element.id),
                                );
                              } else if (element is CustomTextElement) {
                                if (labelGenderIconFieldKeyFromBracketText(element.text) case final gKey?) {
                                  return DraggableImageChip(
                                    key: ValueKey('p${page1 ? '1' : '2'}_gct_${element.id}'),
                                    imagePath: '',
                                    vectorChild: Icon(labelGenderIconForFieldKey(_editorLabelFieldPreview, gKey)),
                                    position: Offset(element.xMm, element.yMm),
                                    widthMm: element.iconWidthMm ?? kLabelGenderIconDefaultWidthMm,
                                    heightMm: element.iconHeightMm ?? kLabelGenderIconDefaultHeightMm,
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    labelWidthMm: _labelWidthMm,
                                    labelHeightMm: _labelHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kLabelCanvasHitPadPx,
                                    labelPanToMmDelta: labelPanToMmDelta,
                                    isSelected: _selectedElement == 'custom:${page1 ? '1' : '2'}:${element.id}',
                                    onTap: () => _deferSetState(() {
                                      _selectedElement = 'custom:${page1 ? '1' : '2'}:${element.id}';
                                      _inlineCanvasCustomKey = null;
                                    }),
                                    onMoved: (pos) {
                                      final wMm = element.iconWidthMm ?? kLabelGenderIconDefaultWidthMm;
                                      final hMm = element.iconHeightMm ?? kLabelGenderIconDefaultHeightMm;
                                      final maxX = math.max(0.0, _labelWidthMm - wMm);
                                      final maxY = math.max(0.0, _labelHeightMm - hMm);
                                      _scheduleTemplateTextPositionUpdate(
                                        page1,
                                        element.copyWith(
                                          xMm: _clampMm(pos.dx, 0, maxX),
                                          yMm: _clampMm(pos.dy, 0, maxY),
                                        ),
                                      );
                                    },
                                    onBoundsChanged: (x, y, w, h) {
                                      _scheduleTemplateTextPositionUpdate(
                                        page1,
                                        element.copyWith(
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
                                        element.copyWith(rotationDegrees: deg),
                                      );
                                    },
                                    onDelete: null,
                                  );
                                } else {
                                  return DraggableChip(
                                    key: ValueKey('p${page1 ? '1' : '2'}_ct_${element.id}_${element.rotationDegrees}_${element.fontFamily}'),
                                    label: element.text.isEmpty ? '(empty)' : (_isPreviewMode ? substituteLabelPlaceholders(element.text, _editorLabelFieldPreview) : element.text),
                                    actualText: element.text,
                                    position: Offset(element.xMm, element.yMm),
                                    fontSize: element.fontSizePt,
                                    fontFamily: element.fontFamily,
                                    bold: element.bold,
                                    italic: element.italic,
                                    rotationDegrees: element.rotationDegrees,
                                    scale: scale,
                                    labelWidthMm: _labelWidthMm,
                                    labelHeightMm: _labelHeightMm,
                                    canvasInsetXPx: 0,
                                    canvasInsetYPx: _kLabelCanvasHitPadPx,
                                    labelPanToMmDelta: labelPanToMmDelta,
                                    isCustom: true,
                                    isInlineEditing: _inlineCanvasCustomKey == 'custom:${page1 ? '1' : '2'}:${element.id}',
                                    isSelected: _selectedElement == 'custom:${page1 ? '1' : '2'}:${element.id}',
                                    onInlineEditingComplete: (v) {
                                      if (!mounted) return;
                                      setState(() {
                                        if (page1) {
                                          _template = _template.copyWith(
                                            page1: _template.page1.withCustomText(element.copyWith(text: v)),
                                          );
                                        } else {
                                          _template = _template.copyWith(
                                            page2: _template.page2.withCustomText(element.copyWith(text: v)),
                                          );
                                        }
                                        _inlineCanvasCustomKey = null;
                                        _inlineCustomTextPaste = null;
                                      });
                                    },
                                    onInlineTextInsertBinding: (fn) => _deferSetState(() => _inlineCustomTextPaste = fn),
                                    onTap: () {
                                      final k = 'custom:${page1 ? '1' : '2'}:${element.id}';
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
                                      final k = 'custom:${page1 ? '1' : '2'}:${element.id}';
                                      setState(() {
                                        _selectedElement = k;
                                        _inlineCanvasCustomKey = null;
                                      });
                                    },
                                    onMoved: (pos) {
                                      _scheduleTemplateTextPositionUpdate(
                                        page1,
                                        element.copyWith(xMm: pos.dx, yMm: pos.dy),
                                      );
                                    },
                                  );
                                }
                              } else if (element is CustomLineElement) {
                                return DraggableLineChip(
                                  key: ValueKey('p${page1 ? '1' : '2'}_line_${element.id}'),
                                  position: Offset(element.xMm, element.yMm),
                                  lengthMm: element.lengthMm,
                                  thicknessPt: element.thicknessPt,
                                  colorArgb: element.colorArgb,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: _labelWidthMm,
                                  labelHeightMm: _labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: _selectedElement == 'line:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => _deferSetState(() {
                                    _selectedElement = 'line:${page1 ? '1' : '2'}:${element.id}';
                                    _inlineCanvasCustomKey = null;
                                  }),
                                  onMoved: (pos) {
                                    _scheduleTemplateLineUpdate(page1, element.copyWith(xMm: pos.dx, yMm: pos.dy));
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    _scheduleTemplateLineUpdate(page1, element.copyWith(xMm: x, yMm: y, lengthMm: w));
                                  },
                                  onRotationChanged: (deg) {
                                    _scheduleTemplateLineUpdate(page1, element.copyWith(rotationDegrees: deg));
                                  },
                                  onDelete: () => _removeCustomLine(page1, element.id),
                                );
                              } else if (element is CustomShapeElement) {
                                return DraggableShapeChip(
                                  key: ValueKey('p${page1 ? '1' : '2'}_shape_${element.id}'),
                                  shapeType: element.shapeType,
                                  position: Offset(element.xMm, element.yMm),
                                  widthMm: element.widthMm,
                                  heightMm: element.heightMm,
                                  strokeThicknessPt: element.strokeThicknessPt,
                                  strokeColorArgb: element.strokeColorArgb,
                                  fillColorArgb: element.fillColorArgb,
                                  rotationDegrees: element.rotationDegrees,
                                  scale: scale,
                                  labelWidthMm: _labelWidthMm,
                                  labelHeightMm: _labelHeightMm,
                                  canvasInsetXPx: 0,
                                  canvasInsetYPx: _kLabelCanvasHitPadPx,
                                  labelPanToMmDelta: labelPanToMmDelta,
                                  isSelected: _selectedElement == 'shape:${page1 ? '1' : '2'}:${element.id}',
                                  onTap: () => _deferSetState(() {
                                    _selectedElement = 'shape:${page1 ? '1' : '2'}:${element.id}';
                                    _inlineCanvasCustomKey = null;
                                  }),
                                  onMoved: (pos) {
                                    _scheduleTemplateShapeUpdate(page1, element.copyWith(xMm: pos.dx, yMm: pos.dy));
                                  },
                                  onBoundsChanged: (x, y, w, h) {
                                    _scheduleTemplateShapeUpdate(page1, element.copyWith(xMm: x, yMm: y, widthMm: w, heightMm: h));
                                  },
                                  onRotationChanged: (deg) {
                                    _scheduleTemplateShapeUpdate(page1, element.copyWith(rotationDegrees: deg));
                                  },
                                  onDelete: () => _removeCustomShape(page1, element.id),
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList();
                          })(),
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


  void _updateZIndex(String sel, int delta) {
    final parts = sel.split(':');
    final type = parts[0];
    final page1 = parts[1] == '1';
    final id = parts[2];
    setState(() {
      if (type == 'custom') {
        final ct = _findCustomText(page1, id);
        if (ct != null) _updateCustomText(page1, ct.copyWith(zIndex: ct.zIndex + delta));
      } else if (type == 'image') {
        final im = _findCustomImage(page1, id);
        if (im != null) _scheduleTemplateImageUpdate(page1, im.copyWith(zIndex: im.zIndex + delta));
      } else if (type == 'line') {
        final ln = _findCustomLine(page1, id);
        if (ln != null) _scheduleTemplateLineUpdate(page1, ln.copyWith(zIndex: ln.zIndex + delta));
      } else if (type == 'shape') {
        final sh = _findCustomShape(page1, id);
        if (sh != null) _scheduleTemplateShapeUpdate(page1, sh.copyWith(zIndex: sh.zIndex + delta));
      }
    });
  }

  Widget _buildElementPanel(String sel, {bool inToolbar = false}) {
    if (sel.startsWith('custom:')) {
      return _buildCustomTextPanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('image:')) {
      return _buildImagePanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('line:')) {
      return _buildLinePanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('shape:')) {
      return _buildShapePanel(sel, inToolbar: inToolbar);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPanelContainer({required Widget child, required bool inToolbar}) {
    final scheme = Theme.of(context).colorScheme;
    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }
    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }

  Widget _buildZIndexControls(String sel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down, size: 20),
          tooltip: 'Send to back',
          onPressed: () => _updateZIndex(sel, -1), // Simplistic, could be improved to find min/max
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          tooltip: 'Send backward',
          onPressed: () => _updateZIndex(sel, -1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          tooltip: 'Bring forward',
          onPressed: () => _updateZIndex(sel, 1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, size: 20),
          tooltip: 'Bring to front',
          onPressed: () => _updateZIndex(sel, 1),
        ),
      ],
    );
  }

  Widget _buildImagePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    
    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete image',
      onPressed: () => _removeCustomImage(page1, id),
    );

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }

  Widget _buildLinePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ln = _findCustomLine(page1, id);
    if (ln == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete line',
      onPressed: () => _removeCustomLine(page1, id),
    );

    // TODO: Add Stroke width/color selectors

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }

  Widget _buildShapePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final sh = _findCustomShape(page1, id);
    if (sh == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete shape',
      onPressed: () => _removeCustomShape(page1, id),
    );

    // TODO: Add Fill/Stroke selectors

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
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
          children: [_buildZIndexControls(sel), const Spacer(), deleteButton],
        ),
      );
      return _buildPanelContainer(child: content, inToolbar: inToolbar);
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
                    child: SyncedFontSizeField(
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
