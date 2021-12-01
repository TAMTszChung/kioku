import 'package:flutter/material.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/src/provider.dart';

class BookOverview extends StatefulWidget {
  final int id;
  const BookOverview(this.id, {Key? key}) : super(key: key);

  final String title = 'Book Overview';

  @override
  State<BookOverview> createState() => _BookOverviewState();
}

class _BookOverviewState extends State<BookOverview> {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<BookProvider>();
    var book = provider.get(widget.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: const Center(
        child: Text(
          'Book Overview',
        ),
      ),
    );
  }
}
