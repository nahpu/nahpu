import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/export/labels/label_template_live_preview.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/specimen_services.dart';

class LabelPageLivePreview extends ConsumerStatefulWidget {
  const LabelPageLivePreview({
    super.key,
    required this.selectedUuidList,
    required this.template,
    required this.layout,
    required this.pageWidthMm,
    required this.pageHeightMm,
  });

  final List<String> selectedUuidList;
  final LabelTemplate template;
  final LabelPrintLayoutOptions layout;
  final double pageWidthMm;
  final double pageHeightMm;

  @override
  ConsumerState<LabelPageLivePreview> createState() =>
      _LabelPageLivePreviewState();
}

class _LabelPageLivePreviewState extends ConsumerState<LabelPageLivePreview> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, String>> _previewData = [];
  double _labelWidthMm = 60.0;
  double _labelHeightMm = 40.0;

  @override
  void initState() {
    super.initState();
    _loadPreviewData();
  }

  @override
  void didUpdateWidget(LabelPageLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUuidList != oldWidget.selectedUuidList ||
        widget.template != oldWidget.template) {
      _loadPreviewData();
    }
  }

  Future<void> _loadPreviewData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = ref.read(databaseProvider);
      final all = await SpecimenServices(ref: ref).getSpecimenList();
      final picked = all
          .where((s) => widget.selectedUuidList.contains(s.uuid))
          .take(500)
          .toList();

      final dataList = <Map<String, String>>[];
      for (final s in picked) {
        final data = await fieldValuesForSpecimen(db, s, ref);
        dataList.add(data);
      }

      final settings = LabelSettingsServices();
      final width = await settings.getLabelWidthMm();
      final height = await settings.getLabelHeightMm();

      if (mounted) {
        setState(() {
          _previewData = dataList;
          _labelWidthMm = width;
          _labelHeightMm = height;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final ptWidth = widget.pageWidthMm * 72.0 / 25.4;
    final ptHeight = widget.pageHeightMm * 72.0 / 25.4;

    final usableW = math.max(
        1.0,
        widget.pageWidthMm -
            widget.layout.pagePadLeftMm -
            widget.layout.pagePadRightMm);
    final usableH = math.max(
        1.0,
        widget.pageHeightMm -
            widget.layout.pagePadTopMm -
            widget.layout.pagePadBottomMm);

    final labelTotalW = _labelWidthMm +
        widget.layout.labelPadLeftMm +
        widget.layout.labelPadRightMm;
    final labelTotalH = _labelHeightMm +
        widget.layout.labelPadTopMm +
        widget.layout.labelPadBottomMm;

    final scale =
        math.min(1.0, math.min(usableW / labelTotalW, usableH / labelTotalH));
    final scaledCellW = widget.layout.colsPerPage > 0
        ? usableW / widget.layout.colsPerPage
        : labelTotalW * scale;
    final scaledCellH = widget.layout.rowsPerPage > 0
        ? usableH / widget.layout.rowsPerPage
        : labelTotalH * scale;

    final cols = widget.layout.colsPerPage > 0
        ? widget.layout.colsPerPage
        : math.max(1, (usableW / scaledCellW).floor());
    final rows = widget.layout.rowsPerPage > 0
        ? widget.layout.rowsPerPage
        : math.max(1, (usableH / scaledCellH).floor());

    final itemsPerPage = cols * rows;
    final totalPages = _previewData.isEmpty
        ? 1
        : (itemsPerPage > 0 ? (_previewData.length / itemsPerPage).ceil() : 1);

    final cellW = scaledCellW * 72.0 / 25.4;
    final cellH = scaledCellH * 72.0 / 25.4;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              for (var p = 0; p < totalPages; p++)
                Padding(
                  padding:
                      EdgeInsets.only(bottom: p < totalPages - 1 ? 32.0 : 0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      width: ptWidth,
                      height: ptHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: widget.layout.pagePadTopMm * 72.0 / 25.4,
                          left: widget.layout.pagePadLeftMm * 72.0 / 25.4,
                          right: widget.layout.pagePadRightMm * 72.0 / 25.4,
                          bottom: widget.layout.pagePadBottomMm * 72.0 / 25.4,
                        ),
                        child: _buildGrid(cols, cellW, cellH, p, itemsPerPage),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(
      int cols, double cellW, double cellH, int pageIndex, int itemsPerPage) {
    if (_previewData.isEmpty) {
      return const Center(
        child: Text(
          'No specimens selected',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: cellW / cellH,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: math.min(
          itemsPerPage, _previewData.length - pageIndex * itemsPerPage),
      itemBuilder: (context, index) {
        final itemIndex = pageIndex * itemsPerPage + index;
        return Container(
          width: cellW,
          height: cellH,
          padding: EdgeInsets.only(
            top: widget.layout.labelPadTopMm * 72.0 / 25.4,
            left: widget.layout.labelPadLeftMm * 72.0 / 25.4,
            right: widget.layout.labelPadRightMm * 72.0 / 25.4,
            bottom: widget.layout.labelPadBottomMm * 72.0 / 25.4,
          ),
          child: IgnorePointer(
            child: ClipRect(
              child: LabelTemplateLivePreview(
                viewportSize: Size(
                  math.max(
                    0.0,
                    cellW -
                        (widget.layout.labelPadLeftMm +
                                widget.layout.labelPadRightMm) *
                            72.0 /
                            25.4,
                  ),
                  math.max(
                    0.0,
                    cellH -
                        (widget.layout.labelPadTopMm +
                                widget.layout.labelPadBottomMm) *
                            72.0 /
                            25.4,
                  ),
                ),
                showHeading: false,
                template: widget.template,
                isDuplex: widget.template.printOptions?.isDuplex ?? false,
                mirrorFront: widget.template.printOptions?.mirrorFront ?? false,
                mirrorBack: widget.template.printOptions?.mirrorBack ?? false,
                labelWidthMm: _labelWidthMm,
                labelHeightMm: _labelHeightMm,
                placeholderValues: _previewData[itemIndex],
              ),
            ),
          ),
        );
      },
    );
  }
}
