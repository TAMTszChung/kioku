import 'package:flutter/material.dart';
import 'package:kioku/component/organism/book_cardview.dart';
import 'package:kioku/component/organism/book_listview.dart';
import 'package:kioku/component/organism/book_pageview.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:provider/provider.dart';

class BookOverview extends StatefulWidget {
  final int id;
  const BookOverview(this.id, {Key? key}) : super(key: key);

  final String title = 'Book Overview';

  @override
  State<BookOverview> createState() => _BookOverviewState();
}

class _BookOverviewState extends State<BookOverview> {
  String _viewMode = 'Book';
  bool addingPage = false;

  Widget showSubView() {
    switch (_viewMode) {
      case 'List':
        return BookListView(widget.id);
      case 'Card':
        return BookCardView(widget.id);
      case 'Book':
      default:
        return BookPageView(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final book = provider.get(widget.id);
    final pageProvider = context.read<BookPageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: <Widget>[
          if (_viewMode == 'Book')
            IconButton(
                onPressed: addingPage
                    ? null
                    : () async {
                        setState(() {
                          addingPage = true;
                        });
                        await pageProvider.insert(BookPage(bookId: widget.id));
                        setState(() {
                          addingPage = false;
                        });
                      },
                icon: const Icon(Icons.add)),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.dashboard_rounded,
              color: Colors.black,
            ),
            onSelected: (String result) {
              setState(() {
                _viewMode = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'View Mode',
                child: Text('View Mode'),
                enabled: false,
              ),
              const PopupMenuDivider(
                height: 1,
              ),
              const PopupMenuItem<String>(
                value: 'Book',
                child: Text('Book'),
              ),
              const PopupMenuItem<String>(
                value: 'Card',
                child: Text('Card'),
              ),
              const PopupMenuItem<String>(
                value: 'List',
                child: Text('List'),
              ),
            ],
          ),
        ],
      ),
      body: showSubView(),
    );
  }
}
