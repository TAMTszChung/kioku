import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/component/molecule/book_page.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:provider/provider.dart';

class BookSlideshowPage extends StatefulWidget {
  final int bookId;
  final int? initialPageId;

  const BookSlideshowPage._internal(this.bookId, this.initialPageId, {Key? key})
      : super(key: key);

  factory BookSlideshowPage(dynamic id, {Key? key}) {
    if (id is int) {
      return BookSlideshowPage._internal(id, null);
    }
    if (id is Iterable<int> && id.length == 2) {
      return BookSlideshowPage._internal(id.first, id.last);
    }
    throw ArgumentError.value(
        id, 'id', 'Must be either bookId or [bookId, pageId]');
  }

  @override
  State<StatefulWidget> createState() => BookSlideShowState();
}

class BookSlideShowState extends State<BookSlideshowPage> {
  static const coverEditRoute = '/cover_edit';
  static const pageEditRoute = '/page_edit';

  late Book book;
  BookPage? page;

  @override
  initState() {
    super.initState();
    book = context.read<BookProvider>().get(widget.bookId);
    if (widget.initialPageId != null) {
      page = context.read<BookPageProvider>().get(widget.initialPageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = context.select<BookPageProvider, List<BookPage>>(
        (p) => p.getAllByBookId(widget.bookId));

    return Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(page == null
              ? 'Cover'
              : 'Page ${page!.pageNumber}/${pages.length}'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  if (page == null) {
                    Navigator.pushNamed(context, coverEditRoute,
                        arguments: widget.bookId);
                  } else {
                    Navigator.pushNamed(context, pageEditRoute,
                        arguments: page!.id);
                  }
                },
                child: const Text("Edit"))
          ],
        ),
        body: CarouselSlider.builder(
            itemCount: pages.length + 1,
            itemBuilder: (_, __, index) {
              late final Widget widget;
              if (index <= 0) {
                widget = BookWidget(book);
              } else {
                widget = BookPageWidget(pages[index - 1]);
              }
              return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(child: widget));
            },
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, _) {
                  setState(() {
                    page = (index > 0) ? pages[index - 1] : null;
                  });
                })));
  }
}
