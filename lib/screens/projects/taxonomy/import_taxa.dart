import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/import/taxon_reader.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

enum DelimiterOverrideOption { auto, comma, tab, semicolon, excel, custom }

class TaxonImportForm extends ConsumerStatefulWidget {
  const TaxonImportForm({super.key});

  @override
  TaxonImportFormState createState() => TaxonImportFormState();
}

class TaxonImportFormState extends ConsumerState<TaxonImportForm> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _customDelimiterController =
      TextEditingController();
  XFile? _filePath;
  List<String> _problems = [];
  late CsvData _csvData;
  bool _hasData = false;
  bool _isRunning = false;
  bool _isLoading = false;
  bool _showAdvancedDelimiterOptions = false;
  bool _customOnlyRecovery = false;
  String? _parseError;
  TaxonFileParseDetails? _parseDetails;
  DelimiterOverrideOption _delimiterOverride = DelimiterOverrideOption.auto;

  @override
  void dispose() {
    _scrollController.dispose();
    _customDelimiterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Taxon'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ScrollableConstrainedLayout(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SelectFileField(
                  filePath: _filePath,
                  isLoading: _isLoading,
                  supportedFormat: '.xlsx, .csv, .tsv',
                  formatLabel: 'Preferred formats',
                  onCleared: () {
                    setState(() {
                      _filePath = null;
                      _hasData = false;
                      _problems = [];
                      _parseError = null;
                      _parseDetails = null;
                      _showAdvancedDelimiterOptions = false;
                      _customOnlyRecovery = false;
                      _delimiterOverride = DelimiterOverrideOption.auto;
                      _customDelimiterController.clear();
                    });
                  },
                  width: 500,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                    _getFile();
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Preferred formats are .xlsx, .csv, and .tsv. NAHPU will '
                  'make a best-effort attempt to parse other file types.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'For known formats, delimiters are automatic: '
                  '.csv uses comma, .tsv uses tab, and .xlsx files use '
                  'Excel spreadsheet parsing.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _parseDetails != null
                    ? _ParseDetailsCard(
                        parserText: _parserLabel(_parseDetails!),
                        delimiterText: _delimiterLabel(_parseDetails!),
                        resolutionText: _resolutionLabel(_parseDetails!),
                      )
                    : const SizedBox.shrink(),
                _parseDetails != null
                    ? const SizedBox(height: 8)
                    : const SizedBox.shrink(),
                const SizedBox(height: 18),
                _hasData ? const ColumnRowTitle() : const SizedBox.shrink(),
                _hasData
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.5),
                        child: CommonScrollbar(
                          scrollController: _scrollController,
                          child: ListView(
                            controller: _scrollController,
                            shrinkWrap: true,
                            children: _buildCsvHeaderField(),
                          ),
                        ))
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                _parseError != null
                    ? Column(
                        children: [
                          Text(
                            'Parsing Error:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _parseError!,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                _problems.isNotEmpty
                    ? Column(
                        children: [
                          Text(
                            'Parsing Issues:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _problems.join(', '),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                _parseDetails != null && _parseError == null
                    ? TertiaryButton(
                        text: _showAdvancedDelimiterOptions
                            ? 'Hide Delimiter Options'
                            : 'Use Custom Delimiter',
                        onPressed: () {
                          setState(() {
                            final nextValue = !_showAdvancedDelimiterOptions;
                            _showAdvancedDelimiterOptions = nextValue;
                          });
                        },
                      )
                    : const SizedBox.shrink(),
                _parseDetails != null && _parseError == null
                    ? const SizedBox(height: 8)
                    : const SizedBox.shrink(),
                _shouldShowDelimiterOverride()
                    ? _DelimiterOverrideSection(
                        option: _delimiterOverride,
                        customDelimiterController: _customDelimiterController,
                        onOptionChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _delimiterOverride = value;
                              _parseError = null;
                              _customOnlyRecovery = false;
                            });
                          }
                        },
                        onRetry: () async {
                          await _parseFile(useOverrideSelection: true);
                        },
                        customOnly: _customOnlyRecovery,
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    SecondaryButton(
                        text: 'Cancel',
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    const SizedBox(
                      width: 20,
                    ),
                    ProgressButton(
                      label: 'Import',
                      isRunning: _isRunning,
                      icon: Icons.download_outlined,
                      onPressed: _isInvalidInput()
                          ? null
                          : () async {
                              await _parseData();
                            },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isInvalidInput() {
    return _problems.isNotEmpty ||
        _isRunning ||
        _filePath == null ||
        _parseError != null ||
        !_hasData;
  }

  List<Widget> _buildCsvHeaderField() {
    List<Widget> headerFields = _csvData.header
        .asMap()
        .entries
        .map((entry) => HeaderInputField(
              header: entry.value,
              value: _csvData.headerMap[entry.key],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _csvData.headerMap[entry.key] = value;
                    _problems = TaxonEntryReader(ref: ref)
                        .findProblems(_csvData.headerMap, rows: _csvData.data);
                  });
                }
              },
            ))
        .toList();
    return headerFields;
  }

  Future<void> _getFile() async {
    setState(() {
      _isLoading = true;
    });
    XFile? file = await FilePickerServices().selectAnyFile();
    if (file != null) {
      setState(() {
        _filePath = file;
        _isLoading = false;
        _hasData = false;
        _problems = [];
        _parseError = null;
        _parseDetails = null;
        _showAdvancedDelimiterOptions = false;
        _customOnlyRecovery = false;
        _delimiterOverride = DelimiterOverrideOption.auto;
        _customDelimiterController.clear();
      });
      await _parseFile();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _parseFile({bool useOverrideSelection = false}) async {
    if (_filePath != null) {
      TaxonEntryReader reader = TaxonEntryReader(ref: ref);
      final parseOptions = useOverrideSelection ||
              _isUnknownExtension ||
              _showAdvancedDelimiterOptions
          ? _buildParseOptions()
          : null;
      try {
        final parsed = await reader.parseFileDetailed(
          File(_filePath!.path),
          options: parseOptions,
        );
        _csvData = parsed.data;
        _problems =
            reader.findProblems(_csvData.headerMap, rows: _csvData.data);
        setState(() {
          _hasData = true;
          _parseError = null;
          _parseDetails = parsed.details;
          _customOnlyRecovery = false;
        });
      } catch (e) {
        final parseException = e is TaxonFileParseException ? e : null;
        setState(() {
          _hasData = false;
          _isRunning = false;
          _showAdvancedDelimiterOptions = true;
          _parseError = _toMessage(e);
          _parseDetails = null;
          _problems = [];
          _customOnlyRecovery = parseException?.code ==
                  TaxonFileParseErrorCode.autoDetectExhausted ||
              parseOptions?.mode == TaxonFileParseMode.auto;
          if (_customOnlyRecovery) {
            _delimiterOverride = DelimiterOverrideOption.custom;
          }
        });
      }
    }
  }

  TaxonFileParseOptions _buildParseOptions() {
    switch (_delimiterOverride) {
      case DelimiterOverrideOption.auto:
        return const TaxonFileParseOptions.auto();
      case DelimiterOverrideOption.comma:
        return const TaxonFileParseOptions.delimiter(',');
      case DelimiterOverrideOption.tab:
        return const TaxonFileParseOptions.delimiter('\t');
      case DelimiterOverrideOption.semicolon:
        return const TaxonFileParseOptions.delimiter(';');
      case DelimiterOverrideOption.excel:
        return const TaxonFileParseOptions.excel();
      case DelimiterOverrideOption.custom:
        return TaxonFileParseOptions.delimiter(_customDelimiterController.text);
    }
  }

  bool _shouldShowDelimiterOverride() {
    return _filePath != null &&
        (_showAdvancedDelimiterOptions ||
            _parseError != null ||
            _customOnlyRecovery);
  }

  String get _selectedExtension {
    if (_filePath == null) {
      return '';
    }
    return p.extension(_filePath!.path).toLowerCase();
  }

  bool get _isUnknownExtension {
    return !_isRecognizedExtension(_selectedExtension);
  }

  bool _isRecognizedExtension(String extension) {
    if (extension == '.csv' || extension == '.tsv') {
      return true;
    }
    return supportedTaxonExcelExtensions.contains(extension);
  }

  String _toMessage(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return raw;
  }

  String _parserLabel(TaxonFileParseDetails details) {
    switch (details.parser) {
      case TaxonResolvedParser.delimited:
        return 'Delimited text parser';
      case TaxonResolvedParser.excel:
        return 'Excel parser';
    }
  }

  String _delimiterLabel(TaxonFileParseDetails details) {
    if (details.parser == TaxonResolvedParser.excel) {
      return 'Not applicable (Excel file)';
    }
    final delimiter = details.delimiter ?? '';
    switch (delimiter) {
      case ',':
        return 'Comma (",")';
      case '\t':
        return r'Tab ("\t")';
      case ';':
        return 'Semicolon (";")';
      default:
        return 'Custom ("${_escapeDelimiter(delimiter)}")';
    }
  }

  String _resolutionLabel(TaxonFileParseDetails details) {
    switch (details.resolution) {
      case TaxonParseResolution.extensionDefault:
        return 'By file extension';
      case TaxonParseResolution.autoDetectExcel:
        return 'Auto detect (Excel)';
      case TaxonParseResolution.autoDetectKnownDelimiter:
        return 'Auto detect (comma/tab/semicolon)';
      case TaxonParseResolution.autoDetectMinedDelimiter:
        return 'Auto detect (text pattern guess)';
      case TaxonParseResolution.manualOverride:
        return 'Manual override';
    }
  }

  String _escapeDelimiter(String delimiter) {
    return delimiter
        .replaceAll('\\', r'\\')
        .replaceAll('\t', r'\t')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r');
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }

  Future<void> _parseData() async {
    try {
      setState(() {
        _isRunning = true;
      });
      ParsedCSVdata data = await TaxonEntryReader(ref: ref).parseData(_csvData);
      setState(() {
        _isRunning = false;
      });
      if (context.mounted) {
        _navigate(data);
      }
    } catch (e) {
      setState(() {
        _isRunning = false;
      });
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _navigate(ParsedCSVdata data) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ImportRecords(importData: data),
      ),
    );
  }
}

class _DelimiterOverrideSection extends StatelessWidget {
  const _DelimiterOverrideSection({
    required this.option,
    required this.customDelimiterController,
    required this.onOptionChanged,
    required this.onRetry,
    required this.customOnly,
  });

  final DelimiterOverrideOption option;
  final TextEditingController customDelimiterController;
  final void Function(DelimiterOverrideOption?) onOptionChanged;
  final VoidCallback onRetry;
  final bool customOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withAlpha(40),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          customOnly
              ? const Text(
                  'Auto detection already tried Excel, comma, tab, and '
                  'semicolon. Enter a custom delimiter to continue.',
                  textAlign: TextAlign.center,
                )
              : DropdownButtonFormField<DelimiterOverrideOption>(
                  decoration: const InputDecoration(
                    labelText: 'Advanced parser override',
                    helperText:
                        'Delimiter is the character between columns (for example: tab is \\t).',
                  ),
                  initialValue: option,
                  items: const [
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.auto,
                      child: CommonDropdownText(text: 'Auto detect'),
                    ),
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.comma,
                      child: CommonDropdownText(text: 'Comma (",")'),
                    ),
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.tab,
                      child: CommonDropdownText(text: r'Tab ("\t")'),
                    ),
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.semicolon,
                      child: CommonDropdownText(text: 'Semicolon (";")'),
                    ),
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.excel,
                      child: CommonDropdownText(text: 'Excel parser'),
                    ),
                    DropdownMenuItem(
                      value: DelimiterOverrideOption.custom,
                      child: CommonDropdownText(text: 'Custom (raw text)'),
                    ),
                  ],
                  onChanged: onOptionChanged,
                ),
          const SizedBox(height: 8),
          (customOnly || option == DelimiterOverrideOption.custom)
              ? CommonTextField(
                  labelText: 'Custom delimiter',
                  hintText: r'Enter raw text (example: | or \t)',
                  controller: customDelimiterController,
                  isLastField: true,
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 8),
          const Text(
            'Excel note: best support is for .xlsx. Older/other Excel formats may fail.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrimaryButton(
                label: 'Retry Parse',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParseDetailsCard extends StatelessWidget {
  const _ParseDetailsCard({
    required this.parserText,
    required this.delimiterText,
    required this.resolutionText,
  });

  final String parserText;
  final String delimiterText;
  final String resolutionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parsing details',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text('Parser: $parserText'),
          Text('Delimiter: $delimiterText'),
          Text('Selected by: $resolutionText'),
        ],
      ),
    );
  }
}

class ColumnRowTitle extends StatelessWidget {
  const ColumnRowTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Column names',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
          ),
          child: Text(
            'Taxon Rank',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class HeaderInputField extends StatelessWidget {
  const HeaderInputField({
    super.key,
    required this.header,
    required this.value,
    required this.onChanged,
  });

  final String header;
  final TaxonEntryHeader? value;
  final void Function(TaxonEntryHeader?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(header.toSentenceCase()),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
          ),
          child: DropdownButton<TaxonEntryHeader>(
            value: value,
            items: TaxonEntryHeader.values
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: CommonDropdownText(text: matchTaxonEntryHeader(e)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}

class ImportRecords extends StatelessWidget {
  const ImportRecords({super.key, required this.importData});

  final ParsedCSVdata importData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Records'),
        automaticallyImplyLeading: false,
        leading: Tooltip(
            message: 'Close',
            child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Dashboard(),
                    ),
                  );
                })),
      ),
      body: SafeArea(
        child: ConstrainedLayout(
          child: Center(
            child: RecordStatistics(importData: importData),
          ),
        ),
      ),
    );
  }
}

class RecordStatistics extends StatelessWidget {
  const RecordStatistics({super.key, required this.importData});

  final ParsedCSVdata importData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          importData.skippedSpecies.isEmpty
              ? const SuccessImport()
              : const WarningImport(),
          const SizedBox(height: 18),
          Text(
            'Imported',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Species: ${importData.importedSpeciesCount}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Family: ${importData.importedFamilyCount}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Text(
            'Skipped',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${importData.skippedSpecies.length}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SkippedImport(skippedRecords: importData.skippedSpecies),
        ],
      ),
    );
  }
}

class SkippedImport extends StatelessWidget {
  const SkippedImport({
    super.key,
    required this.skippedRecords,
  });

  final HashSet<String> skippedRecords;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (var record in skippedRecords)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(record),
          )
      ],
    );
  }
}

class SuccessImport extends StatelessWidget {
  const SuccessImport({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.done,
          color: Colors.green,
          size: 50,
        ),
        Text(
          'Success 🎉🎉🎉',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class WarningImport extends StatelessWidget {
  const WarningImport({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 50,
        ),
        Text(
          'Warning 🙁',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Some records have been skipped.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
