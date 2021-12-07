/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:flutter/material.dart';
import 'package:kioku/model/book_page.dart';

class BookPageWidget extends StatelessWidget {
  final BookPage page;
  final String? routeName;

  const BookPageWidget(this.page, {this.routeName, Key? key}) : super(key: key);

  const BookPageWidget.withRoute(BookPage page, String routeName, {Key? key})
      : this(page, routeName: routeName, key: key);

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
              arguments: <int>[page.bookId, page.id!],
            );
          },
          child: Container(
              decoration: BoxDecoration(
                color: page.color,
                image: page.thumbnail != null
                    ? DecorationImage(
                        image: MemoryImage(page.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 15)),
        ),
      ),
    );
  }
}
