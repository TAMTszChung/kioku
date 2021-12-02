import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class CoveDisplayPage extends StatelessWidget {
  final int id;

  const CoveDisplayPage(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var book =
        context.select<BookProvider, Book>((BookProvider p) => p.get(id));

    return Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Cover'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cover_edit', arguments: id);
                },
                child: const Text("Edit"))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(
            child: BookWidget(book),
          ),
        ));
  }
}
