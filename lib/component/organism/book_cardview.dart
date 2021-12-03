import 'package:flutter/material.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class BookCardView extends StatelessWidget {
  final int id;

  const BookCardView(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final book = provider.get(id);

    const List<Widget> widgets = [
      Center(
        child: Text("Card"),
      ),
      Center(
        child: Text("Card"),
      ),
      Center(
        child: Text("Card"),
      ),
    ];

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: widgets,
    );
  }
}
