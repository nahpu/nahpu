import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/export/report_writer.dart';
import 'package:nahpu/services/platform_services.dart';

class ReportForm extends ConsumerStatefulWidget {
  const ReportForm({super.key});

  @override
  ReportFormState createState() => ReportFormState();
}

class ReportFormState extends ConsumerState<ReportForm> {
  ReportType _reportType = ReportType.speciesCount;
  ReportFmt _reportFmt = ReportFmt.csv;
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  String _fileStem = 'export';
  Directory? _selectedDir;
  late File _savePath;
  bool _hasSaved = false;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a report'),
        automaticallyImplyLeading: false,
      ),
      body: FileOperationPage(
        children: [
          FileFormatIcon(
            path: _reportType == ReportType.coordinate
                ? 'assets/icons/kml.svg'
                : 'assets/icons/csv.svg',
          ),
          DropdownButtonFormField<ReportType>(
            initialValue: _reportType,
            decoration: const InputDecoration(
              labelText: 'Type',
            ),
            items: reportTypeList
                .map((e) => DropdownMenuItem(
                      value: ReportType.values[reportTypeList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ))
                .toList(),
            onChanged: (ReportType? value) {
              if (value != null) {
                setState(() {
                  _reportType = value;
                  if (_reportType == ReportType.coordinate) {
                    _reportFmt = ReportFmt.kml;
                  } else {
                    _reportFmt = ReportFmt.csv;
                  }
                  _hasSaved = false;
                });
              }
            },
          ),
          DropdownButtonFormField<ReportFmt>(
            key: ValueKey(_reportType),
            initialValue: _reportFmt,
            decoration: const InputDecoration(
              labelText: 'Format',
            ),
            items: _reportType == ReportType.coordinate
                ? [
                    ReportFmt.kml,
                    ReportFmt.geojson,
                    ReportFmt.topojson,
                    ReportFmt.shp
                  ]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child:
                              CommonDropdownText(text: reportFmtList[e.index]),
                        ))
                    .toList()
                : [ReportFmt.csv]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child:
                              CommonDropdownText(text: reportFmtList[e.index]),
                        ))
                    .toList(),
            onChanged: (ReportFmt? value) {
              if (value != null) {
                setState(() {
                  _reportFmt = value;
                  _hasSaved = false;
                });
              }
            },
          ),
          FileNameField(
            controller: exportCtr,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _fileStem = value;
                });
              }
            },
          ),
          SelectDirField(
            dirPath: _selectedDir,
            onPressed: () async {
              await _getDir();
            },
            onCanceled: () {
              setState(() {
                _selectedDir = null;
                _hasSaved = false;
              });
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            children: [
              SaveSecondaryButton(hasSaved: _hasSaved),
              !_hasSaved
                  ? ProgressButton(
                      label: 'Save',
                      isRunning: _isRunning,
                      icon: Icons.save_alt_outlined,
                      onPressed: !exportCtr.isValid
                          ? null
                          : () async {
                              setState(() {
                                _isRunning = true;
                              });
                              await _createReport();
                              setState(() {
                                _isRunning = false;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      systemPlatform == PlatformType.desktop
                                          ? 'Report saved to $_savePath'
                                          : 'Report saved!',
                                    ),
                                  ),
                                );
                              }
                            },
                    )
                  : Builder(builder: (context) {
                      return ShareButton(
                        onPressed: () async {
                          await _shareFile(context);
                        },
                      );
                    }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createReport() async {
    try {
      String ext = 'csv';
      if (_reportType == ReportType.coordinate) {
        switch (_reportFmt) {
          case ReportFmt.geojson:
            ext = 'geojson';
            break;
          case ReportFmt.topojson:
            ext = 'topojson';
            break;
          case ReportFmt.shp:
            ext = 'zip';
            break;
          case ReportFmt.kml:
          default:
            ext = 'kml';
            break;
        }
      }
      _savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _fileStem,
        ext: ext,
      ).getSavePath();

      await ReportServices(ref: ref)
          .writeReport(_savePath, _reportType, _reportFmt);
      setState(() {
        _hasSaved = true;
      });
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
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

  Future<void> _shareFile(BuildContext context) async {
    try {
      await FilePickerServices().shareFile(context, _savePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: ErrorText(error: e.toString()),
          ),
        );
      }
    }
  }

  Future<void> _getDir() async {
    final path = await FilePickerServices().selectDir();
    if (path != null) {
      setState(() {
        _selectedDir = path;
      });
    }
  }
}
