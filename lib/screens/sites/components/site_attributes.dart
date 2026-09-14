import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/screens/sites/components/stratigraphy.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/styles/design_tokens.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormCardSectionLabel(text: 'Sedimentology'),
          Sedimentology(id: widget.id),
          const CommonDivider(),
          const FormCardSectionLabel(text: 'Stratigraphy'),
          Stratigraphy(siteId: widget.id),
          CustomFieldForm(owner: CustomFieldOwner.site(widget.id)),
        ],
      ),
    );

    return FormCard(
      title: 'Site attributes',
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
