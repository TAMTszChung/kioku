import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class BookPageView extends StatelessWidget {
  final int id;

  const BookPageView(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);
    var provider = context.watch<BookProvider>();
    var book = provider.get(id);

    List<Widget> widgets = [
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: deviceData.size.width,
            child: BookWidget.withRoute(book, '/cover_display'),
          ),
        ),
      ),
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: 400,
            child: BookWidget(book),
          ),
        ),
      ),
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: 400,
            child: BookWidget(book),
          ),
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(8),
      children: widgets,
    );
  }
}
