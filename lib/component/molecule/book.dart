import 'package:flutter/material.dart';
import 'package:kioku/model/book.dart';

class BookWidget extends StatelessWidget {
  final Book book;
  final String? routeName;
  final double fontSize;

  const BookWidget(this.book, {this.routeName, this.fontSize = 14.0, Key? key})
      : super(key: key);

  const BookWidget.withRoute(Book book, String routeName,
      {double fontSize = 14.0, Key? key})
      : this(book, routeName: routeName, fontSize: fontSize, key: key);

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
                      image: MemoryImage(book.cover!),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Align(
                alignment: const Alignment(0.0, 0.5),
                child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                    ),
                    constraints: BoxConstraints(
                        minHeight: 10, maxHeight: fontSize * 3.5),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ))),
          ),
        ),
      ),
    );
  }
}
