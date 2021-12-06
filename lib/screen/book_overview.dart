import 'package:flutter/material.dart';
import 'package:kioku/component/organism/book_cardview.dart';
import 'package:kioku/component/organism/book_listview.dart';
import 'package:kioku/component/organism/book_pageview.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
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
  String _selectedCategory = 'All';

  Widget showSubView() {
    switch (_viewMode) {
      case 'List':
        return BookListView(widget.id, _selectedCategory);
      case 'Card':
        return BookCardView(widget.id, _selectedCategory);
      case 'Book':
      default:
        return BookPageView(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final book = provider.get(widget.id);
    final pageProvider = context.watch<BookPageProvider>();
    final pages =
        pageProvider.getAllByBookId(widget.id).map((p) => p.copy()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: <Widget>[
          if (_viewMode == 'Book')
            TextButton(
                onPressed: pages.length > 1
                    ? () {
                        Navigator.pushNamed(context, '/page_reorder',
                            arguments: widget.id);
                      }
                    : null,
                child: const Text('Reorder Pages')),
          if (_viewMode == 'Book')
            IconButton(
                onPressed: addingPage
                    ? null
                    : () async {
                        setState(() {
                          addingPage = true;
                        });
                        await pageProvider.insert(BookPage(bookId: widget.id));
                        await provider.update(book);
                        setState(() {
                          addingPage = false;
                        });
                      },
                icon: const Icon(Icons.add)),
          if (_viewMode != 'Book')
            PopupMenuButton<String>(
              icon: _selectedCategory == 'All'
                  ? const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.black,
                    )
                  : const Icon(
                      Icons.filter_alt,
                      color: Colors.black,
                    ),
              onSelected: (String result) {
                setState(() {
                  _selectedCategory = result;
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'Filter By Category',
                    child: Text('Filter By Category'),
                    enabled: false,
                  ),
                  const PopupMenuDivider(
                    height: 1,
                  ),
                  const PopupMenuItem<String>(
                    value: 'All',
                    child: Text('All'),
                  ),
                  ...PageItem.categoryList
                      .map((category) => PopupMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                ];
              },
            ),
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
