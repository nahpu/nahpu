import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_qr_import.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_qr_session.dart';
import 'package:nahpu/services/import/taxon_reader.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

enum _AddTaxonMode { manual, import }

enum _DelimiterOverrideOption { auto, comma, tab, semicolon, excel, custom }

class AddTaxon extends ConsumerStatefulWidget {
  const AddTaxon({super.key});

  @override
  ConsumerState<AddTaxon> createState() => _AddTaxonState();
}

class _AddTaxonState extends ConsumerState<AddTaxon>
    with SingleTickerProviderStateMixin {
  final _manualFormKey = GlobalKey<TaxonRegistryFormState>();
  final _taxonCtr = TaxonRegistryCtrModel.empty();
  final _customDelimiterController = TextEditingController();
  final _importScrollController = ScrollController();

  late final TabController _compactTabController = TabController(
    length: 2,
    vsync: this,
  );

  _AddTaxonMode _mode = _AddTaxonMode.manual;
  XFile? _filePath;
  CsvData? _csvData;
  TaxonImportReview? _review;
  Set<int> _selectedImports = {};
  List<String> _problems = [];
  InferableTaxonClass? _selectedClass;
  TaxonFileParseDetails? _parseDetails;
  String? _parseError;
  bool _isQrImport = false;
  bool _isLoadingFile = false;
  bool _isRunning = false;
  bool _hasData = false;
  bool _showAdvancedDelimiterOptions = false;
  bool _customOnlyRecovery = false;
  _DelimiterOverrideOption _delimiterOverride = _DelimiterOverrideOption.auto;

  @override
  void dispose() {
    _taxonCtr.dispose();
    _customDelimiterController.dispose();
    _importScrollController.dispose();
    _compactTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add taxon'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.lg,
            NahpuSpacing.md,
            NahpuSpacing.lg,
            NahpuSpacing.xxl,
          ),
          child: _buildActions(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= NahpuBreakpoints.desktop;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NahpuSpacing.lg,
                    vertical: NahpuSpacing.md,
                  ),
                  child: SegmentedButton<_AddTaxonMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _AddTaxonMode.manual,
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Manual'),
                      ),
                      ButtonSegment(
                        value: _AddTaxonMode.import,
                        icon: Icon(Icons.move_to_inbox_outlined),
                        label: Text('Import'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selection) => setState(() {
                      _mode = selection.first;
                    }),
                  ),
                ),
                if (!isWide && _mode == _AddTaxonMode.import)
                  TabBar(
                    controller: _compactTabController,
                    tabs: const [
                      Tab(text: 'Setup'),
                      Tab(text: 'Preview'),
                    ],
                  ),
                Expanded(
                  child: _mode == _AddTaxonMode.manual
                      ? _buildManual()
                      : isWide
                      ? _buildWideImport()
                      : TabBarView(
                          controller: _compactTabController,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(NahpuSpacing.lg),
                              child: _TaxonSurfacePanel(
                                child: _buildImportSetup(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(NahpuSpacing.lg),
                              child: _TaxonSurfacePanel(
                                child: _buildImportPreview(),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get _isBusy => _isRunning || _isLoadingFile;

  Widget _buildManual() {
    return TaxonRegistryForm(
      key: _manualFormKey,
      taxonId: null,
      ctr: _taxonCtr,
      isEditing: false,
      showActions: false,
      disposeController: false,
    );
  }

  Widget _buildWideImport() {
    return Padding(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: math.min(
                NahpuContentWidth.form,
                (constraints.maxWidth - NahpuSpacing.lg) / 2,
              ),
              child: _TaxonSurfacePanel(child: _buildImportSetup()),
            ),
            const SizedBox(width: NahpuSpacing.lg),
            Expanded(child: _TaxonSurfacePanel(child: _buildImportPreview())),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSetup() {
    final csvData = _csvData;
    if (_filePath == null && !_isQrImport) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NahpuSpacing.xxl),
          child: _TaxonImportSources(
            sourceName: null,
            isLoading: _isLoadingFile,
            onSelectFile: _isBusy ? null : _getFile,
            onScanQr: _isBusy || !supportsTaxonQrScanning ? null : _scanQr,
            onClear: null,
          ),
        ),
      );
    }
    return CommonScrollbar(
      scrollController: _importScrollController,
      child: ListView(
        key: const ValueKey('taxon-import-setup'),
        controller: _importScrollController,
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        children: [
          _TaxonImportSources(
            sourceName: _isQrImport ? 'NAHPU taxon QR' : _filePath?.name,
            isLoading: _isLoadingFile,
            onSelectFile: _isBusy ? null : _getFile,
            onScanQr: _isBusy || !supportsTaxonQrScanning ? null : _scanQr,
            onClear: _isBusy ? null : _clearFile,
          ),
          if (csvData != null && _hasData) ...[
            if (!csvData.headerMap.containsValue(
              TaxonEntryHeader.taxonClass,
            )) ...[
              const SizedBox(height: NahpuSpacing.xl),
              _ImportClassSelection(
                selectedClass: _selectedClass,
                onChanged: _isBusy
                    ? null
                    : (value) => setState(() {
                        _selectedClass = value;
                        _updateImportValidation();
                      }),
              ),
            ],
            const SizedBox(height: NahpuSpacing.xl),
            Text(
              'Map columns',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NahpuSpacing.md),
            ..._buildHeaderFields(csvData),
          ],
          if (_parseError != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            _ErrorMessage(title: 'Parsing error', message: _parseError!),
          ],
          if (_problems.isNotEmpty) ...[
            const SizedBox(height: NahpuSpacing.lg),
            _ErrorMessage(
              title: 'Check columns',
              message: _problems.join('\n'),
            ),
          ],
          if (_filePath != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            TextButton(
              onPressed: _isBusy
                  ? null
                  : () => setState(() {
                      _showAdvancedDelimiterOptions =
                          !_showAdvancedDelimiterOptions;
                    }),
              child: Text(
                _showAdvancedDelimiterOptions
                    ? 'Hide advanced options'
                    : 'Advanced options',
              ),
            ),
          ],
          if (_shouldShowDelimiterOverride()) ...[
            const SizedBox(height: NahpuSpacing.lg),
            if (_parseDetails != null) ...[
              _ParseDetailsCard(details: _parseDetails!),
              const SizedBox(height: NahpuSpacing.lg),
            ],
            _DelimiterOverrideSection(
              option: _delimiterOverride,
              customDelimiterController: _customDelimiterController,
              customOnly: _customOnlyRecovery,
              onOptionChanged: _isBusy
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _delimiterOverride = value;
                        _parseError = null;
                        _customOnlyRecovery = false;
                        _review = null;
                        _selectedImports = {};
                      });
                    },
              onRetry: _isBusy ? null : _retryParse,
            ),
          ],
          if (_hasData) ...[
            const SizedBox(height: NahpuSpacing.xxl),
            Align(
              alignment: Alignment.center,
              child: PrimaryButton(
                label: 'Review taxa',
                icon: Icons.preview_outlined,
                onPressed:
                    _isBusy || _parseError != null || _problems.isNotEmpty
                    ? null
                    : _reviewImport,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportPreview() {
    final review = _review;
    if (review == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(NahpuSpacing.xxl),
          child: Text(
            'Select a file or scan a taxon QR to preview imports.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final selectable = review.selectableCandidates.length;
    final allSelected =
        selectable > 0 &&
        review.selectableCandidates.every(
          (candidate) =>
              _selectedImports.contains(review.candidates.indexOf(candidate)),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.lg,
            NahpuSpacing.xl,
            NahpuSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$selectable taxa ready',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: _isBusy || selectable == 0 || allSelected
                    ? null
                    : _selectAllImports,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: _isBusy || _selectedImports.isEmpty
                    ? null
                    : () => setState(_selectedImports.clear),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        if (review.alreadyRegisteredCount > 0 || review.duplicateCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xl),
            child: Text(
              '${review.alreadyRegisteredCount} already registered · '
              '${review.duplicateCount} duplicate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: review.candidates.length,
            itemBuilder: (context, index) {
              final candidate = review.candidates[index];
              final status = switch (candidate.status) {
                TaxonImportStatus.ready => null,
                TaxonImportStatus.alreadyRegistered => 'Already registered',
                TaxonImportStatus.duplicateInFile => 'Duplicate',
              };
              final details = [
                candidate.rank.label,
                if (candidate.data.taxonClass.trim().isNotEmpty)
                  candidate.data.taxonClass,
                if (candidate.data.taxonFamily.trim().isNotEmpty)
                  candidate.data.taxonFamily,
                if (candidate.data.commonName?.trim().isNotEmpty == true)
                  candidate.data.commonName!,
                ...status == null ? const <String>[] : [status],
              ].join(' · ');
              return CheckboxListTile(
                value: _selectedImports.contains(index),
                onChanged: candidate.isSelectable && !_isBusy
                    ? (selected) => setState(() {
                        if (selected == true) {
                          _selectedImports.add(index);
                        } else {
                          _selectedImports.remove(index);
                        }
                      })
                    : null,
                title: Text(
                  candidate.displayName,
                  style: candidate.usesItalicName
                      ? const TextStyle(fontStyle: FontStyle.italic)
                      : null,
                ),
                subtitle: details.isEmpty ? null : Text(details),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final review = _review;
    final selectedCount = review == null ? 0 : _selectedImports.length;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: NahpuSpacing.xl,
      runSpacing: NahpuSpacing.md,
      children: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: _isBusy ? () {} : () => Navigator.of(context).pop(),
        ),
        PrimaryButton(
          label: _mode == _AddTaxonMode.import
              ? 'Import $selectedCount selected'
              : 'Add',
          icon: _mode == _AddTaxonMode.import
              ? Icons.download_outlined
              : Icons.add,
          onPressed: _isBusy
              ? null
              : _mode == _AddTaxonMode.import
              ? review == null || _selectedImports.isEmpty
                    ? null
                    : _importSelected
              : () => _manualFormKey.currentState?.submit(),
        ),
      ],
    );
  }

  List<Widget> _buildHeaderFields(CsvData csvData) {
    return csvData.header.asMap().entries.map((entry) {
      return _TaxonHeaderMappingRow(
        header: entry.value,
        value: csvData.headerMap[entry.key],
        onChanged: _isBusy
            ? null
            : (value) {
                if (value == null) return;
                setState(() {
                  if (value == TaxonEntryHeader.taxonClass ||
                      csvData.headerMap[entry.key] ==
                          TaxonEntryHeader.taxonClass) {
                    _selectedClass = null;
                  }
                  csvData.headerMap[entry.key] = value;
                  _updateImportValidation();
                });
              },
      );
    }).toList();
  }

  void _updateImportValidation() {
    final data = _csvData;
    _problems = data == null
        ? []
        : findTaxonImportProblems(
            data.headerMap,
            rows: data.data,
            selectedClass: _selectedClass,
          );
    _review = null;
    _selectedImports = {};
  }

  Future<void> _scanQr() async {
    setState(() => _isRunning = true);
    try {
      final mode = await showDialog<TaxonQrImportMode>(
        context: context,
        builder: (_) => const TaxonQrImportModeDialog(),
      );
      if (mode == null || !mounted) return;
      final review = await Navigator.of(context).push<TaxonImportReview>(
        MaterialPageRoute(builder: (_) => TaxonQrImportScreen(mode: mode)),
      );
      if (review == null || !mounted) return;
      _clearFile();
      setState(() {
        _isQrImport = true;
        _review = review;
      });
      _selectAllImports();
      _compactTabController.animateTo(1);
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _retryParse() async {
    setState(() => _isLoadingFile = true);
    try {
      await _parseFile(useOverrideSelection: true);
    } finally {
      if (mounted) setState(() => _isLoadingFile = false);
    }
  }

  Future<void> _getFile() async {
    setState(() => _isLoadingFile = true);
    try {
      final file = await FilePickerServices().selectAnyFile();
      if (file == null || !mounted) return;
      setState(() {
        _isQrImport = false;
        _filePath = file;
        _csvData = null;
        _review = null;
        _selectedImports = {};
        _problems = [];
        _selectedClass = null;
        _parseError = null;
        _parseDetails = null;
        _hasData = false;
        _showAdvancedDelimiterOptions = false;
        _customOnlyRecovery = false;
        _delimiterOverride = _DelimiterOverrideOption.auto;
        _customDelimiterController.clear();
      });
      await _parseFile();
    } finally {
      if (mounted) setState(() => _isLoadingFile = false);
    }
  }

  void _clearFile() {
    setState(() {
      _isQrImport = false;
      _filePath = null;
      _csvData = null;
      _review = null;
      _selectedImports = {};
      _problems = [];
      _selectedClass = null;
      _parseError = null;
      _parseDetails = null;
      _hasData = false;
      _showAdvancedDelimiterOptions = false;
      _customOnlyRecovery = false;
      _delimiterOverride = _DelimiterOverrideOption.auto;
      _customDelimiterController.clear();
    });
  }

  Future<void> _parseFile({bool useOverrideSelection = false}) async {
    final filePath = _filePath;
    if (filePath == null) return;
    final reader = TaxonFileParser();
    final parseOptions =
        useOverrideSelection ||
            _isUnknownExtension ||
            _showAdvancedDelimiterOptions
        ? _buildParseOptions()
        : null;
    try {
      final parsed = await reader.parseFileDetailed(
        File(filePath.path),
        options: parseOptions,
      );
      if (!mounted) return;
      final data = parsed.data;
      setState(() {
        _csvData = data;
        _selectedClass = null;
        _updateImportValidation();
        _parseDetails = parsed.details;
        _parseError = null;
        _hasData = true;
        _review = null;
        _selectedImports = {};
        _customOnlyRecovery = false;
      });
    } catch (error) {
      if (!mounted) return;
      final exception = error is TaxonFileParseException ? error : null;
      setState(() {
        _csvData = null;
        _selectedClass = null;
        _hasData = false;
        _parseError = _toMessage(error);
        _parseDetails = null;
        _problems = [];
        _review = null;
        _selectedImports = {};
        _showAdvancedDelimiterOptions = true;
        _customOnlyRecovery =
            exception?.code == TaxonFileParseErrorCode.autoDetectExhausted ||
            parseOptions?.mode == TaxonFileParseMode.auto;
        if (_customOnlyRecovery) {
          _delimiterOverride = _DelimiterOverrideOption.custom;
        }
      });
    }
  }

  Future<void> _reviewImport() async {
    final data = _csvData;
    if (data == null) return;
    try {
      setState(() => _isRunning = true);
      final review = await TaxonEntryReader(
        ref: ref,
      ).reviewData(data, selectedClass: _selectedClass);
      if (!mounted) return;
      setState(() {
        _review = review;
        _selectedImports = {
          for (var index = 0; index < review.candidates.length; index++)
            if (review.candidates[index].isSelectable) index,
        };
        _isRunning = false;
      });
      if (_compactTabController.index != 1 && mounted) {
        _compactTabController.animateTo(1);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isRunning = false);
        _showError(error.toString());
      }
    }
  }

  Future<void> _importSelected() async {
    final review = _review;
    if (review == null || _selectedImports.isEmpty) return;
    try {
      setState(() => _isRunning = true);
      final result = await TaxonEntryReader(
        ref: ref,
      ).importSelected(review, _selectedImports);
      if (!mounted) return;
      Navigator.of(context).pop(
        TaxonImportResult(
          importedTaxaCount: result.importedTaxaCount,
          importedFamilyCount: result.importedFamilyCount,
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _isRunning = false);
        _showError(error.toString());
      }
    }
  }

  void _selectAllImports() {
    final review = _review;
    if (review == null) return;
    setState(() {
      _selectedImports = {
        for (var index = 0; index < review.candidates.length; index++)
          if (review.candidates[index].isSelectable) index,
      };
    });
  }

  TaxonFileParseOptions _buildParseOptions() {
    return switch (_delimiterOverride) {
      _DelimiterOverrideOption.auto => const TaxonFileParseOptions.auto(),
      _DelimiterOverrideOption.comma => const TaxonFileParseOptions.delimiter(
        ',',
      ),
      _DelimiterOverrideOption.tab => const TaxonFileParseOptions.delimiter(
        '\t',
      ),
      _DelimiterOverrideOption.semicolon =>
        const TaxonFileParseOptions.delimiter(';'),
      _DelimiterOverrideOption.excel => const TaxonFileParseOptions.excel(),
      _DelimiterOverrideOption.custom => TaxonFileParseOptions.delimiter(
        _customDelimiterController.text,
      ),
    };
  }

  bool _shouldShowDelimiterOverride() {
    return _filePath != null &&
        (_showAdvancedDelimiterOptions ||
            _parseError != null ||
            _customOnlyRecovery);
  }

  String get _selectedExtension =>
      _filePath == null ? '' : p.extension(_filePath!.path).toLowerCase();

  bool get _isUnknownExtension =>
      !(_selectedExtension == '.csv' ||
          _selectedExtension == '.tsv' ||
          supportedTaxonExcelExtensions.contains(_selectedExtension));

  String _toMessage(Object error) {
    final raw = error.toString();
    return raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '')
        : raw;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TaxonSurfacePanel extends StatelessWidget {
  const _TaxonSurfacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _ImportClassSelection extends StatelessWidget {
  const _ImportClassSelection({
    required this.selectedClass,
    required this.onChanged,
  });

  final InferableTaxonClass? selectedClass;
  final ValueChanged<InferableTaxonClass?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final classification = selectedClass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the class shared by all rows',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: NahpuSpacing.md),
        DropdownButton<InferableTaxonClass>(
          key: const ValueKey('taxon-import-class-selection'),
          isExpanded: true,
          hint: const Text('Class for all rows'),
          value: classification,
          items: InferableTaxonClass.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.label)),
              )
              .toList(),
          onChanged: onChanged,
        ),
        if (classification != null) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'Kingdom: ${classification.kingdom} · Phylum: ${classification.phylum}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _TaxonHeaderMappingRow extends StatelessWidget {
  const _TaxonHeaderMappingRow({
    required this.header,
    required this.value,
    required this.onChanged,
  });

  final String header;
  final TaxonEntryHeader? value;
  final ValueChanged<TaxonEntryHeader?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: DropdownButtonFormField<TaxonEntryHeader>(
        key: ValueKey('taxon-import-${header.toLowerCase()}'),
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(labelText: header.toSentenceCase()),
        items: TaxonEntryHeader.values
            .map(
              (entry) => DropdownMenuItem(
                value: entry,
                child: CommonDropdownText(text: matchTaxonEntryHeader(entry)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ParseDetailsCard extends StatelessWidget {
  const _ParseDetailsCard({required this.details});

  final TaxonFileParseDetails details;

  @override
  Widget build(BuildContext context) {
    final parser = details.parser == TaxonResolvedParser.excel
        ? 'Excel parser'
        : 'Delimited text parser';
    final delimiter = details.parser == TaxonResolvedParser.excel
        ? 'Not applicable (Excel file)'
        : details.delimiter == '\t'
        ? r'Tab ("\t")'
        : details.delimiter ?? 'Custom';
    return Container(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parsing details',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: NahpuSpacing.sm),
          Text('Parser: $parser'),
          Text('Delimiter: $delimiter'),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: NahpuSpacing.md),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}

class _DelimiterOverrideSection extends StatelessWidget {
  const _DelimiterOverrideSection({
    required this.option,
    required this.customDelimiterController,
    required this.customOnly,
    required this.onOptionChanged,
    required this.onRetry,
  });

  final _DelimiterOverrideOption option;
  final TextEditingController customDelimiterController;
  final bool customOnly;
  final ValueChanged<_DelimiterOverrideOption?>? onOptionChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withAlpha(40),
          width: NahpuStroke.regular,
        ),
        borderRadius: BorderRadius.circular(NahpuRadius.md),
      ),
      child: Column(
        children: [
          customOnly
              ? const Text(
                  'Enter a custom delimiter to continue.',
                  textAlign: TextAlign.center,
                )
              : DropdownButtonFormField<_DelimiterOverrideOption>(
                  decoration: const InputDecoration(labelText: 'Parser'),
                  initialValue: option,
                  items: const [
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.auto,
                      child: CommonDropdownText(text: 'Auto detect'),
                    ),
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.comma,
                      child: CommonDropdownText(text: 'Comma (",")'),
                    ),
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.tab,
                      child: CommonDropdownText(text: r'Tab ("\t")'),
                    ),
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.semicolon,
                      child: CommonDropdownText(text: 'Semicolon (";")'),
                    ),
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.excel,
                      child: CommonDropdownText(text: 'Excel parser'),
                    ),
                    DropdownMenuItem(
                      value: _DelimiterOverrideOption.custom,
                      child: CommonDropdownText(text: 'Custom (raw text)'),
                    ),
                  ],
                  onChanged: onOptionChanged,
                ),
          if (customOnly || option == _DelimiterOverrideOption.custom)
            CommonTextField(
              labelText: 'Custom delimiter',
              hintText: r'Enter raw text (example: | or \t)',
              controller: customDelimiterController,
              isLastField: true,
            ),
          const SizedBox(height: NahpuSpacing.md),
          PrimaryButton(
            label: 'Retry parse',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _TaxonImportSources extends StatelessWidget {
  const _TaxonImportSources({
    required this.sourceName,
    required this.isLoading,
    required this.onSelectFile,
    required this.onScanQr,
    required this.onClear,
  });

  final String? sourceName;
  final bool isLoading;
  final VoidCallback? onSelectFile;
  final VoidCallback? onScanQr;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Supported inputs:',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: NahpuSpacing.xs),
        Text(
          'CSV (.csv), TSV (.tsv), Excel (.xlsx), NAHPU taxon QR',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: NahpuSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: NahpuSpacing.lg,
          runSpacing: NahpuSpacing.lg,
          children: [
            OutlinedButton.icon(
              onPressed: onScanQr,
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: const Text('Scan QR'),
            ),
            FilledButton.icon(
              onPressed: onSelectFile,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: NahpuControlSize.iconSmall,
                      child: CircularProgressIndicator(
                        strokeWidth: NahpuStroke.regular,
                      ),
                    )
                  : const Icon(Icons.file_open_outlined),
              label: Text(isLoading ? 'Reading file…' : 'Select file'),
            ),
          ],
        ),
        if (!supportsTaxonQrScanning) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'QR scanning is unavailable on this platform.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (sourceName != null) ...[
          const SizedBox(height: NahpuSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(sourceName!, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                tooltip: 'Clear import',
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
