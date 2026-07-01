import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/specimen_selection.dart';
import 'package:nahpu/screens/exports/labels/components/column_picker.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';

class LabelPreviewSpecimenSelectionScreen extends ConsumerStatefulWidget {
  const LabelPreviewSpecimenSelectionScreen({
    super.key,
    required this.selectedUuid,
  });

  final String? selectedUuid;

  @override
  ConsumerState<LabelPreviewSpecimenSelectionScreen> createState() =>
      _LabelPreviewSpecimenSelectionScreenState();
}

class _LabelPreviewSpecimenSelectionScreenState
    extends ConsumerState<LabelPreviewSpecimenSelectionScreen> {
  List<String> _visibleColumnIds = [];

  @override
  void initState() {
    super.initState();
    _loadColumns();
  }

  Future<void> _loadColumns() async {
    final db = ref.read(databaseProvider);
    final settings = LabelSettingsServices();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Specimen for Preview'),
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
