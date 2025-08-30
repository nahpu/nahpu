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
import 'package:share_plus/share_plus.dart';

class TaxonImportForm extends ConsumerStatefulWidget {
  const TaxonImportForm({super.key});

  @override
  TaxonImportFormState createState() => TaxonImportFormState();
}

class TaxonImportFormState extends ConsumerState<TaxonImportForm> {
  TaxonImportFmt _fmt = TaxonImportFmt.csv;
  final ScrollController _scrollController = ScrollController();
  XFile? _filePath;
  List<String> _problems = [];
  late CsvData _csvData;
  bool _hasData = false;
  bool _isRunning = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
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
                InputFormatField(
                  inputFmt: _fmt,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _fmt = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 18),
                SelectFileField(
                  filePath: _filePath,
                  isLoading: _isLoading,
                  onCleared: () {
                    setState(() {
                      _filePath = null;
                      _hasData = false;
                      _problems = [];
                    });
                  },
                  width: 500,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                    _getFile();
                  },
                ),
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
    return _problems.isNotEmpty || _isRunning || _filePath == null;
  }

  List<Widget> _buildCsvHeaderField() {
    List<Widget> headerFields = _csvData.header
        .map((e) => HeaderInputField(
              header: _csvData.header[_csvData.header.indexOf(e)],
              value: _csvData.headerMap[_csvData.header.indexOf(e)],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _csvData.headerMap[_csvData.header.indexOf(e)] = value;
                    _problems = TaxonEntryReader(ref: ref)
                        .findProblems(_csvData.headerMap);
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
    XFile? file = await FilePickerServices().selectFile(taxonImportFmt);
    if (file != null) {
      setState(() {
        _filePath = file;
        _isLoading = false;
        _parseFile();
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _parseFile() async {
    if (_filePath != null) {
      TaxonEntryReader reader = TaxonEntryReader(ref: ref);
      try {
        _csvData = await reader.parseCsv(File(_filePath!.path));
        _problems = reader.findProblems(_csvData.headerMap);
        setState(() {
          _hasData = true;
        });
      } catch (e) {
        setState(() {
          _hasData = false;
          _isRunning = false;
        });
        if (context.mounted) {
          _showError(e.toString());
        }
      }
    }
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

class InputFormatField extends StatelessWidget {
  const InputFormatField({
    super.key,
    required this.inputFmt,
    required this.onChanged,
  });

  final TaxonImportFmt inputFmt;
  final void Function(TaxonImportFmt?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: 'Input Format',
      ),
      initialValue: inputFmt,
      items: taxonImportFmt
          .map((e) => DropdownMenuItem(
                value: TaxonImportFmt.values[taxonImportFmt.indexOf(e)],
                child: CommonDropdownText(text: e.label ?? ''),
              ))
          .toList(),
      onChanged: onChanged,
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
