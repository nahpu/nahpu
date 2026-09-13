import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/screens/sites/components/stratigraphy.dart';

class SiteAttributes extends StatefulWidget {
  const SiteAttributes({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
  });

  final int id;
  final bool useHorizontalLayout;

  @override
  State<SiteAttributes> createState() => _SiteAttributesState();
}

class _SiteAttributesState extends State<SiteAttributes> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sedimentology', style: Theme.of(context).textTheme.titleMedium),
          Sedimentology(id: widget.id),
          const CommonDivider(),
          Text('Stratigraphy', style: Theme.of(context).textTheme.titleMedium),
          const Stratigraphy(),
        ],
      ),
    );

    return FormCard(
      title: 'Site attributes',
      infoContent: const InfoContainer(
        content: [SedimentologyInfoContent(), StratigraphyInfoContent()],
      ),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      isExpanded: widget.useHorizontalLayout,
      child: widget.useHorizontalLayout
          ? CommonScrollbar(
              scrollController: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: sections,
              ),
            )
          : sections,
    );
  }
}
