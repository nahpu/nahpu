import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nahpu/screens/templates/components/dialogs/template_exists_dialog.dart';
import 'package:nahpu/screens/templates/components/dialogs/template_image_picker_dialog.dart';
import 'package:nahpu/screens/templates/components/layout/template_border_panel.dart';
import 'package:nahpu/screens/templates/components/layout/template_editor_loading.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:nahpu/services/template_service.dart';
import 'package:nahpu/services/template_editor_service.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/screens/templates/components/layout/template_editor_scaffold.dart';
import 'package:nahpu/screens/templates/components/properties/text_element_editor.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/screens/templates/template_preview_specimen_selection.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/providers/projects.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TemplateService _templateService = const TemplateService();
  final DocumentSettingsServices _documentSettings = DocumentSettingsServices();
  final TemplateEditorService _editorService = TemplateEditorService();

  Template _template = DefaultTemplate.defaultTemplate();
  List<String> _savedNames = [];
  String? _lastSavedJson;
  final List<_EditorStateSnapshot> _undoStack = [];
  final List<_EditorStateSnapshot> _redoStack = [];

  bool get _isDirty {
    if (_lastSavedJson == null) return false;
    return _lastSavedJson != _templateWithCurrentPrintOptions().toJsonString();
  }

  bool _loading = true;
  double _zoom = 1.0;
  bool _showGrid = true;
  bool _snapEnabled = false;
  bool _canvasMovementLocked = false;
  late bool _isDuplex;
  late bool _mirrorFront;
  late bool _mirrorBack;
  late double _templateWidthMm;
  late double _templateHeightMm;

  /// Currently selected element for the properties panel.
  /// Format: `builtin:<componentId>`, `custom:<page>:<ct_id>`, or `image:<page>:<img_id>`.
  String? _selectedElement;

  /// Custom text key (`custom:1:ct_0`) when typing on the canvas; null = preview only.
  int _customIdCounter = 0;
  int _imageIdCounter = 0;

  String? _selectedSpecimenUuid;

  /// First record’s `[field]` map for canvas preview (sex icons, etc.).
  Map<String, String> _editorTemplateFieldPreview = {};

  final bool _isPreviewMode = true;
  final String _fieldDisplayOption = 'short';

  bool _templateBorderPanelOpen = false;
  int _templateBorderPanelSession = 0;

  final GlobalKey _templateStackKeyPage1 = GlobalKey();
  final GlobalKey _templateStackKeyPage2 = GlobalKey();

  bool _imageTemplateFlushScheduled = false;
  CustomImageElement? _pendingImageTemplate;
  bool? _pendingImageTemplatePage1;

  bool _textTemplateFlushScheduled = false;
  CustomTextElement? _pendingTextTemplate;
  bool? _pendingTextTemplatePage1;

  CustomLineElement? _pendingLineTemplate;
  bool? _pendingLineTemplatePage1;
  bool _lineTemplateFlushScheduled = false;

  CustomShapeElement? _pendingShapeTemplate;
  bool? _pendingShapeTemplatePage1;
  bool _shapeTemplateFlushScheduled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabControllerTick);
    _loadInitial();
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
      return const TemplateEditorLoading();
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _promptExitWithoutSaving();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: TemplateEditorScaffold(
        savedNames: _savedNames,
        template: _template,
        isDuplex: _isDuplex,
        isPage1: _isPage1,
        mirrorFront: _mirrorFront,
        mirrorBack: _mirrorBack,
        templateWidthMm: _templateWidthMm,
        templateHeightMm: _templateHeightMm,
        isBorderPanelOpen: _templateBorderPanelOpen,
        showGrid: _showGrid,
        snapEnabled: _snapEnabled,
        canvasMovementLocked: _canvasMovementLocked,
        selectedElement: _selectedElement,
        tabController: _tabController,
        zoom: _zoom,
        isPreviewMode: _isPreviewMode,
        editorTemplateFieldPreview: _editorTemplateFieldPreview,
        frontStackKey: _templateStackKeyPage1,
        backStackKey: _templateStackKeyPage2,
        templatePanGlobalDeltaToMm: _templatePanGlobalDeltaToMm,
        fieldDisplayOption: _fieldDisplayOption,
        canDeleteSavedTemplate: _canDeleteSavedTemplate,
        onCreateNewTemplate: _createNewTemplate,
        onSaveTemplate: _saveTemplate,
        onSaveAsTemplate: _promptSaveAsTemplate,
        onImportTemplate: _importTemplate,
        onExportTemplate: _exportTemplate,
        onDeleteTemplate: _confirmDeleteTemplate,
        onTemplateSelected: _loadTemplate,
        onDescriptionChanged: _updateTemplateDescription,
        onDuplexChanged: _setDuplex,
        onPageChanged: _selectPage,
        onTemplateSizeChanged: _setTemplateSize,
        onAddText: () => _addCustomText(_isPage1),
        onAddImage: () => _showAddImageDialog(_isPage1),
        onAddLine: () => _addCustomLine(_isPage1),
        onAddShape: () => _addCustomShape(_isPage1),
        onMirrorToggled: _toggleCurrentMirror,
        onBorderPanelToggled: _toggleTemplateBorderPanel,
        onGridToggled: () => _deferSetState(() => _showGrid = !_showGrid),
        onSnapToggled: () => _deferSetState(() => _snapEnabled = !_snapEnabled),
        onCanvasMovementLockToggled: () => _deferSetState(
          () => _canvasMovementLocked = !_canvasMovementLocked,
        ),
        onSelectPreviewSpecimen: _selectSpecimenForPreview,
        onClearSelection: _clearSelection,
        onSelectElement: _selectElement,
        onStartInlineEditing: _startInlineEditing,
        onScheduleTemplateImageUpdate: _scheduleTemplateImageUpdate,
        onRemoveCustomImage: _removeCustomImage,
        onScheduleTemplateTextPositionUpdate:
            _scheduleTemplateTextPositionUpdate,
        onScheduleTemplateLineUpdate: _scheduleTemplateLineUpdate,
        onRemoveCustomLine: _removeCustomLine,
        onScheduleTemplateShapeUpdate: _scheduleTemplateShapeUpdate,
        onRemoveCustomShape: _removeCustomShape,
        onUpdateCustomText: _updateCustomText,
        onDeleteCustomText: _deleteCustomText,
        onUpdateCustomImage: _scheduleTemplateImageUpdate,
        onUpdateCustomLine: _updateCustomLine,
        onUpdateCustomShape: _updateCustomShape,
        onDismissProperties: _clearSelection,
        onZoomChanged: _setZoom,
        onUndo: _undo,
        onRedo: _redo,
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
        onDuplicateElement: _duplicateElement,
        onDragStateChanged: _onDragStateChanged,
        borderPanel: TemplateBorderPanel(
          session: _templateBorderPanelSession,
          outline: _template.outline,
          onOutlineChanged: _setTemplateOutline,
          onDismiss: _toggleTemplateBorderPanel,
        ),
      ),
    );
  }

  bool get _isPage1 => _tabController.index == 0;

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

  Offset? _templatePanGlobalDeltaToMm(
    GlobalKey stackKey,
    Offset globalPosition,
    Offset globalDelta,
    double scale,
  ) {
    return globalDragDeltaToTemplateMm(
      stackKey: stackKey,
      globalPosition: globalPosition,
      globalDelta: globalDelta,
      scalePxPerMm: scale,
    );
  }

  void _deferSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(fn);
    });
  }

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

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  Future<void> _loadInitial() async {
    _isDuplex = await _documentSettings.getDuplex();
    _mirrorFront = await _documentSettings.getMirrorFront();
    _mirrorBack = await _documentSettings.getMirrorBack();
    _templateWidthMm = await _documentSettings.getDocumentWidthMm();
    _templateHeightMm = await _documentSettings.getDocumentHeightMm();
    final currentName = await _documentSettings.getCurrentTemplateName();
    if (currentName != null && currentName.isNotEmpty) {
      final t = await _templateService.getTemplate(currentName);
      if (t != null) {
        _template = t;
        _templateWidthMm = t.widthMm;
        _templateHeightMm = t.heightMm;
        await _documentSettings.setDocumentWidthMm(t.widthMm);
        await _documentSettings.setDocumentHeightMm(t.heightMm);
        final o = t.printOptions;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
          await _documentSettings.setDuplex(_isDuplex);
          await _documentSettings.setMirrorFront(_mirrorFront);
          await _documentSettings.setMirrorBack(_mirrorBack);
        }
      }
    }
    _syncDuplexTabIndex();
    _savedNames = await _templateService.listTemplateNames();
    _syncIdCountersFromTemplate();
    await _loadEditorTemplateFieldPreview();
    _lastSavedJson = _templateWithCurrentPrintOptions().toJsonString();
    if (mounted) {
      setState(() => _loading = false);
      unawaited(_warmCustomTextGoogleFonts());
    }
  }

  Future<void> _loadEditorTemplateFieldPreview() async {
    try {
      if (mounted) {
        setState(() {
          _selectedSpecimenUuid = null;
          _editorTemplateFieldPreview = {};
        });
      }
      final db = ref.read(databaseProvider);
      Map<String, String> m = {};
      final recordType = _template.recordType;

      if (recordType == RecordType.specimenRecord) {
        final list = await SpecimenServices(ref: ref).getSpecimenList();
        if (list.isNotEmpty) {
          final firstSpecimen = list.first;
          m = await documentFieldValuesForSpecimen(db, firstSpecimen, ref);
          if (mounted) {
            setState(() {
              _selectedSpecimenUuid = firstSpecimen.uuid;
              _editorTemplateFieldPreview = m;
            });
          }
        }
      } else if (recordType == RecordType.site) {
        final list = await SiteServices(ref: ref).getAllSites();
        if (list.isNotEmpty) {
          final firstSite = list.first;
          m = await documentFieldValuesForSite(db, firstSite, ref);
          if (mounted) {
            setState(() {
              _editorTemplateFieldPreview = m;
            });
          }
        }
      } else if (recordType == RecordType.collEvent) {
        final list = await CollEventServices(ref: ref).getAllCollEvents();
        if (list.isNotEmpty) {
          final firstEvent = list.first;
          m = await documentFieldValuesForCollEvent(db, firstEvent, ref);
          if (mounted) {
            setState(() {
              _editorTemplateFieldPreview = m;
            });
          }
        }
      } else if (recordType == RecordType.narrative) {
        final list = await NarrativeServices(ref: ref).getAllNarrative();
        if (list.isNotEmpty) {
          final firstNarrative = list.first;
          m = await documentFieldValuesForNarrative(db, firstNarrative, ref);
          if (mounted) {
            setState(() {
              _editorTemplateFieldPreview = m;
            });
          }
        }
      } else if (recordType == RecordType.none) {
        final projectUuid = ref.read(projectUuidProvider);
        if (projectUuid.isNotEmpty) {
          try {
            final proj =
                await ProjectServices(ref: ref).getProjectByUuid(projectUuid);
            for (var entry in proj.toJson().entries) {
              m['project::${entry.key}'] = entry.value?.toString() ?? '';
            }
          } catch (_) {}

          try {
            final personnel = await PersonnelServices(ref: ref)
                .getPersonnelByProjectUuid(projectUuid);
            if (personnel.isNotEmpty) {
              final Set<String> keys = {};
              final List<Map<String, dynamic>> jsonList =
                  personnel.map((p) => p.toJson()).toList();
              for (final json in jsonList) {
                keys.addAll(json.keys);
              }
              for (final key in keys) {
                final joined = jsonList
                    .map((json) => json[key]?.toString() ?? '')
                    .where((v) => v.isNotEmpty)
                    .join(' | ');
                m['personnel::$key'] = joined;
              }
            }
          } catch (_) {}
        }

        // Apply fallback values for preview in the editor
        m.putIfAbsent('project::name', () => 'Active Project');
        m.putIfAbsent('project::uuid', () => 'active-project-uuid');
        m.putIfAbsent(
            'project::description', () => 'Active Project Description');
        m.putIfAbsent(
            'project::principalInvestigator', () => 'Active Investigator');
        m.putIfAbsent('project::location', () => 'Active Project Location');
        m.putIfAbsent('project::timeZone', () => 'UTC');
        m.putIfAbsent('project::startDate', () => '2026-01-01');
        m.putIfAbsent('project::endDate', () => '2026-12-31');

        m.putIfAbsent('personnel::name', () => 'Active Personnel');
        m.putIfAbsent('personnel::role', () => 'Active Personnel Role');
        m.putIfAbsent('personnel::initial', () => 'AP');
        m.putIfAbsent('personnel::email', () => 'active@example.com');
        m.putIfAbsent('personnel::affiliation', () => 'Active Affiliation');

        if (mounted) {
          setState(() {
            _editorTemplateFieldPreview = m;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _warmCustomTextGoogleFonts() async {
    try {
      for (final page in [_template.page1, _template.page2]) {
        for (final ct in page.customTexts) {
          if (!templateCanvasFontUsesGoogle(ct.fontFamily)) continue;
          await preloadGoogleFontForTemplateCanvas(
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

  TemplatePrintOptions get _currentPrintOptions => TemplatePrintOptions(
        isDuplex: _isDuplex,
        mirrorFront: _mirrorFront,
        mirrorBack: _mirrorBack,
      );

  Template _templateWithCurrentPrintOptions({String? name}) {
    return _template.copyWith(
      name: name,
      printOptions: _currentPrintOptions,
      widthMm: _templateWidthMm,
      heightMm: _templateHeightMm,
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

  Future<void> _setDuplex(bool duplex) async {
    _pushToUndo();
    _deferSetState(() {
      _isDuplex = duplex;
      if (!duplex && _tabController.index != 0) {
        _tabController.index = 0;
      }
      _selectedElement = null;
    });
    await _documentSettings.setDuplex(duplex);
  }

  void _selectPage(int index) {
    _tabController.animateTo(index);
    _clearSelection();
  }

  void _setTemplateSize(double widthMm, double heightMm) {
    _pushToUndo();
    _deferSetState(() {
      _templateWidthMm = widthMm;
      _templateHeightMm = heightMm;
    });
  }

  void _setZoom(double zoom) {
    _deferSetState(() => _zoom = zoom.clamp(0.5, 4.0).toDouble());
  }

  void _updateTemplateDescription(String description) {
    _pushToUndo();
    setState(() {
      _template = _template.copyWith(description: description);
    });
  }

  Future<void> _toggleCurrentMirror() async {
    _pushToUndo();
    if (_isPage1) {
      final next = !_mirrorFront;
      _deferSetState(() => _mirrorFront = next);
      await _documentSettings.setMirrorFront(next);
    } else {
      final next = !_mirrorBack;
      _deferSetState(() => _mirrorBack = next);
      await _documentSettings.setMirrorBack(next);
    }
  }

  void _toggleTemplateBorderPanel() {
    _deferSetState(() {
      _templateBorderPanelOpen = !_templateBorderPanelOpen;
      if (_templateBorderPanelOpen) {
        _templateBorderPanelSession++;
        _selectedElement = null;
      }
    });
  }

  void _clearSelection() {
    if (!mounted) return;
    setState(() {
      _selectedElement = null;
    });
  }

  void _selectElement(String id) {
    _deferSetState(() {
      _selectedElement = id;
      _templateBorderPanelOpen = false;
    });
  }

  void _startInlineEditing(String id) {
    _selectElement(id);
    _showTextEditDialog(id);
  }

  // --- Custom text helpers ---
  void _addCustomText(bool page1) {
    _addCustomTextWithLabel(page1, 'Text');
  }

  void _addCustomTextWithLabel(bool page1, String text) {
    _pushToUndo();
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
      _templateBorderPanelOpen = false;
    });
  }

  void _addCustomLine(bool page1) {
    _pushToUndo();
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
      _templateBorderPanelOpen = false;
    });
  }

  void _addCustomShape(bool page1) {
    _pushToUndo();
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
      _templateBorderPanelOpen = false;
    });
  }

  void _updateCustomText(bool page1, CustomTextElement element) {
    _pushToUndo();
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
          recordType: _template.recordType,
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
          recordType: _template.recordType,
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
    _pushToUndo();
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
    _pushToUndo();
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
    _pushToUndo();
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
    _pushToUndo();
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
    _pushToUndo();
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
    _pushToUndo();
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

  /// Picks an image file and copies it into the template images folder; returns
  /// the stored path or null.
  Future<String?> _copyPickedImageToLogos() async {
    final added = await _editorService.copyPickedImageToLogos();
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
      builder: (dialogContext) => TemplateImagePickerDialog(
        onUpload: () async {
          Navigator.pop(dialogContext);
          await _uploadAndUseImage(page1);
        },
        onImageSelected: (imagePath) {
          Navigator.pop(dialogContext);
          _placeCustomImage(page1, imagePath);
        },
      ),
    );
  }

  void _setTemplateOutline(TemplateOutline? outline) {
    _pushToUndo();
    _deferSetState(() {
      if (outline == null) {
        _template = _template.copyWith(clearOutline: true);
      } else {
        _template = _template.copyWith(outline: outline);
      }
    });
  }

  void _placeCustomImage(bool page1, String filePath) {
    _pushToUndo();
    final id = 'img_$_imageIdCounter';
    _imageIdCounter++;
    final dw = (_templateWidthMm * 0.35).clamp(8.0, 48.0);
    final dh = (_templateHeightMm * 0.35).clamp(8.0, 48.0);
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
      _templateBorderPanelOpen = false;
    });
  }

  Future<_CreateTemplateResult?> _promptCreateNewTemplate() async {
    final taken = _savedNames.toSet();
    return showDialog<_CreateTemplateResult>(
      context: context,
      builder: (context) => _CreateTemplateDialog(takenNames: taken),
    );
  }

  Future<void> _createNewTemplate() async {
    final result = await _promptCreateNewTemplate();
    if (result == null || result.name.isEmpty) return;

    final fresh = DefaultTemplate.defaultTemplate(
      result.name,
      result.recordType,
      result.description,
    ).copyWith(
      printOptions: _currentPrintOptions,
      widthMm: _templateWidthMm,
      heightMm: _templateHeightMm,
    );
    await _templateService.saveTemplate(fresh);
    _savedNames = await _templateService.listTemplateNames();

    await _documentSettings.setMirrorFront(false);
    await _documentSettings.setMirrorBack(false);
    final duplex = await _documentSettings.getDuplex();
    if (!mounted) return;
    setState(() {
      _template = fresh;
      _mirrorFront = false;
      _mirrorBack = false;
      _isDuplex = duplex;
      _selectedElement = null;
      _syncIdCountersFromTemplate();
      _syncDuplexTabIndex();
    });
    await _loadEditorTemplateFieldPreview();
    _lastSavedJson = _templateWithCurrentPrintOptions().toJsonString();
  }

  Future<void> _saveTemplate() async {
    await _saveTemplateWithName(_template.name);
  }

  Future<void> _promptSaveAsTemplate() async {
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
      _lastSavedJson = merged.toJsonString();
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
          builder: (context) => TemplateExistsDialog(templateName: name),
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
        await _documentSettings.setDuplex(o.isDuplex);
        await _documentSettings.setMirrorFront(o.mirrorFront);
        await _documentSettings.setMirrorBack(o.mirrorBack);
      }
      await _documentSettings.setDocumentWidthMm(merged.widthMm);
      await _documentSettings.setDocumentHeightMm(merged.heightMm);
      if (!mounted) return;
      _savedNames = await _templateService.listTemplateNames();
      if (!mounted) return;
      setState(() {
        _template = merged;
        _templateWidthMm = merged.widthMm;
        _templateHeightMm = merged.heightMm;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
        }
        _syncIdCountersFromTemplate();
        _syncDuplexTabIndex();
      });
      await _loadEditorTemplateFieldPreview();
      _lastSavedJson = _templateWithCurrentPrintOptions().toJsonString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported and saved "$name"')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import failed or file invalid')),
      );
    }
  }

  Future<void> _loadTemplate(String name) async {
    final t = await _templateService.getTemplate(name);
    if (t != null) {
      await _documentSettings.setCurrentTemplateName(name);
      final o = t.printOptions;
      if (o != null) {
        await _documentSettings.setDuplex(o.isDuplex);
        await _documentSettings.setMirrorFront(o.mirrorFront);
        await _documentSettings.setMirrorBack(o.mirrorBack);
      }
      await _documentSettings.setDocumentWidthMm(t.widthMm);
      await _documentSettings.setDocumentHeightMm(t.heightMm);
      if (!mounted) return;
      setState(() {
        _template = t;
        _templateWidthMm = t.widthMm;
        _templateHeightMm = t.heightMm;
        if (o != null) {
          _isDuplex = o.isDuplex;
          _mirrorFront = o.mirrorFront;
          _mirrorBack = o.mirrorBack;
        }
        _syncIdCountersFromTemplate();
        _selectedElement = null;
        _syncDuplexTabIndex();
      });
      await _loadEditorTemplateFieldPreview();
      _lastSavedJson = _templateWithCurrentPrintOptions().toJsonString();
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
    final fresh = DefaultTemplate.defaultTemplate();
    if (!mounted) return;
    await _documentSettings.setMirrorFront(false);
    await _documentSettings.setMirrorBack(false);
    _mirrorFront = false;
    _mirrorBack = false;
    _isDuplex = await _documentSettings.getDuplex();
    if (!mounted) return;
    setState(() {
      _template = fresh;
      _syncIdCountersFromTemplate();
      _selectedElement = null;
      _syncDuplexTabIndex();
    });
    await _loadEditorTemplateFieldPreview();
    _lastSavedJson = _templateWithCurrentPrintOptions().toJsonString();
  }

  Future<bool> _promptExitWithoutSaving() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'Do you want to save the changes to the template before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Don't save (Discard)
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () async {
              await _saveTemplate();
              if (context.mounted) {
                Navigator.pop(context, true); // Save and Leave
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _selectSpecimenForPreview() async {
    final recordType = _template.recordType;
    final db = ref.read(databaseProvider);

    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplatePreviewSpecimenSelectionScreen(
          selectedUuid: _selectedSpecimenUuid,
          recordType: recordType,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        if (recordType == RecordType.specimenRecord) {
          final s = await SpecimenServices(ref: ref).getSpecimen(result);
          final m = await documentFieldValuesForSpecimen(db, s, ref);
          setState(() {
            _selectedSpecimenUuid = result;
            _editorTemplateFieldPreview = m;
          });
        } else if (recordType == RecordType.site) {
          final list = await SiteServices(ref: ref).getAllSites();
          final s =
              list.firstWhere((element) => element.id.toString() == result);
          final m = await documentFieldValuesForSite(db, s, ref);
          setState(() {
            _selectedSpecimenUuid = result;
            _editorTemplateFieldPreview = m;
          });
        } else if (recordType == RecordType.collEvent) {
          final list = await CollEventServices(ref: ref).getAllCollEvents();
          final s =
              list.firstWhere((element) => element.id.toString() == result);
          final m = await documentFieldValuesForCollEvent(db, s, ref);
          setState(() {
            _selectedSpecimenUuid = result;
            _editorTemplateFieldPreview = m;
          });
        } else if (recordType == RecordType.narrative) {
          final list = await NarrativeServices(ref: ref).getAllNarrative();
          final s =
              list.firstWhere((element) => element.id.toString() == result);
          final m = await documentFieldValuesForNarrative(db, s, ref);
          setState(() {
            _selectedSpecimenUuid = result;
            _editorTemplateFieldPreview = m;
          });
        }
      } catch (_) {}
    }
  }

  void _pushToUndo() {
    _undoStack.add(_EditorStateSnapshot(
      template: _template.copyWith(),
      isDuplex: _isDuplex,
      mirrorFront: _mirrorFront,
      mirrorBack: _mirrorBack,
      templateWidthMm: _templateWidthMm,
      templateHeightMm: _templateHeightMm,
    ));
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_EditorStateSnapshot(
      template: _template.copyWith(),
      isDuplex: _isDuplex,
      mirrorFront: _mirrorFront,
      mirrorBack: _mirrorBack,
      templateWidthMm: _templateWidthMm,
      templateHeightMm: _templateHeightMm,
    ));
    final snapshot = _undoStack.removeLast();
    setState(() {
      _template = snapshot.template;
      _isDuplex = snapshot.isDuplex;
      _mirrorFront = snapshot.mirrorFront;
      _mirrorBack = snapshot.mirrorBack;
      _templateWidthMm = snapshot.templateWidthMm;
      _templateHeightMm = snapshot.templateHeightMm;
    });
    _documentSettings.setDuplex(snapshot.isDuplex);
    _documentSettings.setMirrorFront(snapshot.mirrorFront);
    _documentSettings.setMirrorBack(snapshot.mirrorBack);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_EditorStateSnapshot(
      template: _template.copyWith(),
      isDuplex: _isDuplex,
      mirrorFront: _mirrorFront,
      mirrorBack: _mirrorBack,
      templateWidthMm: _templateWidthMm,
      templateHeightMm: _templateHeightMm,
    ));
    final snapshot = _redoStack.removeLast();
    setState(() {
      _template = snapshot.template;
      _isDuplex = snapshot.isDuplex;
      _mirrorFront = snapshot.mirrorFront;
      _mirrorBack = snapshot.mirrorBack;
      _templateWidthMm = snapshot.templateWidthMm;
      _templateHeightMm = snapshot.templateHeightMm;
    });
    _documentSettings.setDuplex(snapshot.isDuplex);
    _documentSettings.setMirrorFront(snapshot.mirrorFront);
    _documentSettings.setMirrorBack(snapshot.mirrorBack);
  }

  void _duplicateElement(String sel) {
    final selection = TemplateSelection.parse(sel);
    if (selection == null) return;

    _pushToUndo();

    final page1 = selection.page1;
    switch (selection.type) {
      case TemplateElementType.text:
        final original = _findCustomText(page1, selection.id);
        if (original != null) {
          final id = 'ct_$_customIdCounter';
          _customIdCounter++;
          final duplicated = original.copyWith(
            id: id,
            xMm: original.xMm + 4,
            yMm: original.yMm + 4,
          );
          setState(() {
            if (page1) {
              _template = _template.copyWith(
                page1: _template.page1.withCustomText(duplicated),
              );
            } else {
              _template = _template.copyWith(
                page2: _template.page2.withCustomText(duplicated),
              );
            }
            _selectedElement = 'custom:${page1 ? '1' : '2'}:$id';
          });
        }
      case TemplateElementType.image:
        final original = _findCustomImage(page1, selection.id);
        if (original != null) {
          final id = 'img_$_imageIdCounter';
          _imageIdCounter++;
          final duplicated = original.copyWith(
            id: id,
            xMm: original.xMm + 4,
            yMm: original.yMm + 4,
          );
          setState(() {
            if (page1) {
              _template = _template.copyWith(
                page1: _template.page1.withCustomImage(duplicated),
              );
            } else {
              _template = _template.copyWith(
                page2: _template.page2.withCustomImage(duplicated),
              );
            }
            _selectedElement = 'image:${page1 ? '1' : '2'}:$id';
          });
        }
      case TemplateElementType.line:
        final original = _findCustomLine(page1, selection.id);
        if (original != null) {
          final id = 'line_$_customIdCounter';
          _customIdCounter++;
          final duplicated = original.copyWith(
            id: id,
            xMm: original.xMm + 4,
            yMm: original.yMm + 4,
          );
          setState(() {
            if (page1) {
              _template = _template.copyWith(
                page1: _template.page1.withCustomLine(duplicated),
              );
            } else {
              _template = _template.copyWith(
                page2: _template.page2.withCustomLine(duplicated),
              );
            }
            _selectedElement = 'line:${page1 ? '1' : '2'}:$id';
          });
        }
      case TemplateElementType.shape:
        final original = _findCustomShape(page1, selection.id);
        if (original != null) {
          final id = 'shape_$_customIdCounter';
          _customIdCounter++;
          final duplicated = original.copyWith(
            id: id,
            xMm: original.xMm + 4,
            yMm: original.yMm + 4,
          );
          setState(() {
            if (page1) {
              _template = _template.copyWith(
                page1: _template.page1.withCustomShape(duplicated),
              );
            } else {
              _template = _template.copyWith(
                page2: _template.page2.withCustomShape(duplicated),
              );
            }
            _selectedElement = 'shape:${page1 ? '1' : '2'}:$id';
          });
        }
    }
  }

  void _onDragStateChanged(bool dragging) {
    if (dragging) {
      _pushToUndo();
    }
  }

  CustomImageElement? _findCustomImage(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    try {
      return page.customImages.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  CustomLineElement? _findCustomLine(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    try {
      return page.customLines.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  CustomShapeElement? _findCustomShape(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    try {
      return page.customShapes.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

class _EditorStateSnapshot {
  final Template template;
  final bool isDuplex;
  final bool mirrorFront;
  final bool mirrorBack;
  final double templateWidthMm;
  final double templateHeightMm;

  _EditorStateSnapshot({
    required this.template,
    required this.isDuplex,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.templateWidthMm,
    required this.templateHeightMm,
  });
}

class _CreateTemplateResult {
  _CreateTemplateResult({
    required this.name,
    required this.recordType,
    required this.description,
  });
  final String name;
  final RecordType recordType;
  final String description;
}

class _CreateTemplateDialog extends StatefulWidget {
  const _CreateTemplateDialog({required this.takenNames});

  final Set<String> takenNames;

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  late final TextEditingController _ctrl;
  late final TextEditingController _descCtrl;
  final _formKey = GlobalKey<FormState>();
  RecordType _recordType = RecordType.specimenRecord;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create new template'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ctrl,
              decoration: const InputDecoration(
                labelText: 'Template name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter a name';
                if (widget.takenNames.contains(t)) {
                  return 'A template with this name already exists';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(
                    context,
                    _CreateTemplateResult(
                      name: _ctrl.text.trim(),
                      recordType: _recordType,
                      description: _descCtrl.text.trim(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecordType>(
              initialValue: _recordType,
              decoration: const InputDecoration(
                labelText: 'Record type',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: RecordType.specimenRecord,
                  child: Text('Specimen'),
                ),
                DropdownMenuItem(
                  value: RecordType.site,
                  child: Text('Site'),
                ),
                DropdownMenuItem(
                  value: RecordType.collEvent,
                  child: Text('Collecting Event'),
                ),
                DropdownMenuItem(
                  value: RecordType.narrative,
                  child: Text('Narrative'),
                ),
                DropdownMenuItem(
                  value: RecordType.none,
                  child: Text('None'),
                ),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _recordType = v;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(
                context,
                _CreateTemplateResult(
                  name: _ctrl.text.trim(),
                  recordType: _recordType,
                  description: _descCtrl.text.trim(),
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
