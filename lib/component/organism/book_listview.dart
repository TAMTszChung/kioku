import 'package:flutter/material.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class BookListView extends StatelessWidget {
  final int id;
  const BookListView(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final book = provider.get(id);

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: [],
    );
  }
}
