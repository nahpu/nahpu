import 'package:flutter/widgets.dart';

class ColumnList extends StatefulWidget {
  const ColumnList({super.key, required this.columnNames});

  final List<String> columnNames;

  @override
  State<ColumnList> createState() => _ColumnListState();
}

class _ColumnListState extends State<ColumnList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.columnNames.length,
      itemBuilder: (context, index) {
        return Text(widget.columnNames[index]);
      },
    );
  }
}
