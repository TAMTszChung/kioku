import 'package:flutter/material.dart';
import 'package:kioku/model/book.dart';

class BookOverview extends StatefulWidget {
  final Book book;
  const BookOverview(this.book, {Key? key}) : super(key: key);

  final String title = 'Book Overview';

  @override
  State<BookOverview> createState() => _BookOverviewState();
}

class _BookOverviewState extends State<BookOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: const Center(
        child: Text(
          'Book Overview',
        ),
      ),
    );
  }
}
