import 'dart:convert';

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
    return Center(
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
              color: book.cover == null ? book.color : null,
              image: book.cover != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(book.cover!)),
                      fit: BoxFit.cover,
                    )
                  : null,
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
    );
  }
}
