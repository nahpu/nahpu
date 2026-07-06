import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/screens/shared/document/record_selection.dart';
import 'package:nahpu/screens/shared/document/column_picker.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

class TemplatePreviewSpecimenSelectionScreen extends ConsumerStatefulWidget {
  const TemplatePreviewSpecimenSelectionScreen({
    super.key,
    required this.selectedUuid,
    required this.recordType,
  });

  final String? selectedUuid;
  final RecordType recordType;

  @override
  ConsumerState<TemplatePreviewSpecimenSelectionScreen> createState() =>
      _TemplatePreviewSpecimenSelectionScreenState();
}

class _TemplatePreviewSpecimenSelectionScreenState
    extends ConsumerState<TemplatePreviewSpecimenSelectionScreen> {
  List<String> _visibleColumnIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.recordType == RecordType.specimenRecord) {
      _loadColumns();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recordType == RecordType.none) {
      return const Scaffold(
        body: Center(
          child: Text('No preview records for this type'),
        ),
      );
    }
    if (widget.recordType == RecordType.site) {
      return SiteSelectionScreen(
        isSingleSelection: true,
        selectedIds: widget.selectedUuid != null
            ? {int.tryParse(widget.selectedUuid!) ?? 0}
                .where((e) => e != 0)
                .toSet()
            : const {},
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            Navigator.pop(context, selected.first.toString());
          }
        },
      );
    } else if (widget.recordType == RecordType.collEvent) {
      return EventSelectionScreen(
        isSingleSelection: true,
        selectedIds: widget.selectedUuid != null
            ? {int.tryParse(widget.selectedUuid!) ?? 0}
                .where((e) => e != 0)
                .toSet()
            : const {},
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            Navigator.pop(context, selected.first.toString());
          }
        },
      );
    } else if (widget.recordType == RecordType.narrative) {
      return NarrativeSelectionScreen(
        isSingleSelection: true,
        selectedIds: widget.selectedUuid != null
            ? {int.tryParse(widget.selectedUuid!) ?? 0}
                .where((e) => e != 0)
                .toSet()
            : const {},
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            Navigator.pop(context, selected.first.toString());
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen Selection for Preview'),
      ),
      body: SafeArea(
        child: SpecimenSelectionView(
          selectedUuidList:
              widget.selectedUuid != null ? {widget.selectedUuid!} : const {},
          visibleColumnIds: _visibleColumnIds,
          isSingleSelection: true,
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) {
              Navigator.pop(context, selected.first);
            }
          },
          onColumnsChanged: _pickColumns,
        ),
      ),
    );
  }

  Future<void> _loadColumns() async {
    final db = ref.read(databaseProvider);
    final settings = DocumentSettingsServices();
    final storedCols = await settings.getPrintSpecimenTableColumnIds();
    var visible = normalizePrintSpecimenTableColumnIds(storedCols, db);
    if (visible.isEmpty) {
      visible = normalizePrintSpecimenTableColumnIds(
        List<String>.from(kDefaultPrintSpecimenTableColumnIds),
        db,
      );
    }
    if (mounted) {
      setState(() {
        _visibleColumnIds = visible;
      });
    }
  }

  Future<void> _pickColumns() async {
    List<String>? result;

    if (systemPlatform == PlatformType.mobile) {
      result = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Table columns'),
                automaticallyImplyLeading: false,
              ),
              body: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    } else {
      result = await showDialog<List<String>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Table columns'),
            content: SizedBox(
              width: 420,
              height: 420,
              child: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    }

    if (result != null && mounted) {
      setState(() {
        _visibleColumnIds = result!;
      });
    }
  }
}
