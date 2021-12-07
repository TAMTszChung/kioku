/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/component/molecule/book_page.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';

class BookPageView extends StatefulWidget {
  static const slideshowRoute = '/book_slideshow';

  final int id;

  const BookPageView(this.id, {Key? key}) : super(key: key);

  @override
  State<BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView> {
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final provider = context.watch<BookProvider>();
    final book = provider.get(widget.id).copy();
    final List<BookPage> pages = context
        .select<BookPageProvider, List<BookPage>>(
            (BookPageProvider p) => p.getAllByBookId(widget.id))
        .map((e) => e.copy())
        .toList();

    final List<Widget> widgets = [
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            height: deviceData.size.width,
            child: BookWidget.withRoute(book, BookPageView.slideshowRoute),
          ),
        ),
      ),
      ...(pages.map((BookPage page) => Center(
            child: LongPressDraggable<BookPage>(
              data: page,
              onDragStarted: () {
                setState(() {
                  dragging = true;
                });
              },
              onDraggableCanceled: (v, o) {
                setState(() {
                  dragging = false;
                });
              },
              feedback: SizedBox(
                height: deviceData.size.width,
                child: BookPageWidget(page),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: deviceData.size.width,
                  child: BookPageWidget.withRoute(
                      page, BookPageView.slideshowRoute),
                ),
              ),
            ),
          )))
    ];

    return Column(
      children: [
        Expanded(
            child: ListView(
          padding: const EdgeInsets.all(8),
          children: widgets,
        )),
        if (dragging)
          DragTarget<BookPage>(
            builder: (context, candidateItems, rejectedItems) {
              return Container(
                decoration: BoxDecoration(
                  color: candidateItems.isNotEmpty ? Colors.red[700] : null,
                ),
                constraints: BoxConstraints(
                    minHeight: 50,
                    maxHeight: 80,
                    minWidth: deviceData.size.width,
                    maxWidth: deviceData.size.width),
                child: const Icon(Icons.delete),
              );
            },
            onAccept: (page) async {
              final copiedPages = pages.map((e) => e.copy()).toList();
              copiedPages.remove(page);
              for (int i = 0; i < copiedPages.length; i++) {
                copiedPages[i].pageNumber = i + 1;
              }

              //delete this page
              await context
                  .read<BookPageProvider>()
                  .setAll(widget.id, copiedPages);
              //fetch all items cuz items are also removed
              await context.read<PageItemProvider>().fetchAll();

              //update the book last edit time
              await provider.update(book);
              setState(() {
                dragging = false;
              });
            },
          )
      ],
    );
  }
}
