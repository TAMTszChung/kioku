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

    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 40,
      crossAxisCount: 2,
      children: [],
    );
  }
}
