import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';

class AttributeForm extends StatefulWidget {
  const AttributeForm({super.key, required this.children});

  final List<Widget> children;

  @override
  State<AttributeForm> createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Specimen Attributes',
      infoContent: const AttributeInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
        height: 484,
        child: CommonScrollbar(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ScrollPhysics(),
            child: Column(children: widget.children),
          ),
        ),
      ),
    );
  }
}

class AttributeInfoContent extends StatelessWidget {
  const AttributeInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content:
              'Measurements and other biological attributes of the '
              'specimen, including age, sex, reproductive condition, and '
              'taxon-specific observations.',
        ),
      ],
    );
  }
}
