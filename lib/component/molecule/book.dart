import 'package:flutter/material.dart';
import 'package:kioku/model/book.dart';

class BookWidget extends StatelessWidget {
  final Book book;
  final String? routeName;

  const BookWidget(this.book, {this.routeName, Key? key}) : super(key: key);

  const BookWidget.withRoute(Book book, String routeName, {Key? key})
      : this(book, routeName: routeName, key: key);

  @override
  Widget build(BuildContext context) {
    //var deviceData = MediaQuery.of(context);

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 210 / 297,
          child: GestureDetector(
            onTap: () {
              if (routeName == null) {
                return;
              }
              Navigator.pushNamed(
                context,
                routeName!,
                arguments: book.id,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: book.color,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Align(
                  alignment: const Alignment(0.0, 0.5),
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                      ),
                      constraints:
                          const BoxConstraints(minHeight: 10, maxHeight: 30),
                      width: double.infinity,
                      child: Center(
                        child: Text(book.title),
                      ))),
            ),
          ),
        ),
      ),
    );
  }
}
