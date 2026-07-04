import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';

class MeasurementForm extends StatefulWidget {
  const MeasurementForm({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  State<MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<MeasurementForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Measurements',
      infoContent: const MeasurementInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
        height: 484,
        child: CommonScrollbar(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ScrollPhysics(),
            child: Column(
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

class MeasurementInfoContent extends StatelessWidget {
  const MeasurementInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        content: 'Standard measurements of the specimen. If you are unsure of '
            'how to take a measurement, please refer to the '
            'measurement guide for respective taxa.',
      )
    ]);
  }
}
