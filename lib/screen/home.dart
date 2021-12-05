import 'package:flutter/material.dart';
import 'package:kioku/component/atom/input_dialog.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final String title = 'Kioku';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortType = 'Title (Ascending)';

  void sortBook(List<Book> list, String type) {
    setState(() {
      switch (type) {
        case 'Title (Ascending)':
          list.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Title (Descending)':
          list.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'Create Date (Ascending)':
          list.sort((a, b) => a.createTime.compareTo(b.createTime));
          break;
        case 'Create Date (Descending)':
          list.sort((a, b) => b.createTime.compareTo(a.createTime));
          break;
        case 'Last Modified (Ascending)':
          list.sort((a, b) => a.lastModifiedTime.compareTo(b.lastModifiedTime));
          break;
        case 'Last Modified (Descending)':
          list.sort((a, b) => b.lastModifiedTime.compareTo(a.lastModifiedTime));
          break;
        default:
          list.sort((a, b) => a.title.compareTo(b.title));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final books = provider.books;
    sortBook(books, _sortType);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                final result = await showTextInputDialog(
                  context,
                  title: 'Book Title',
                  hintText: 'Title',
                  okText: 'OK',
                  cancelText: 'Cancel',
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                  maxLength: 35,
                );

                if (result != null) {
                  provider.insert(Book(title: result));
                }
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.sort,
              ),
              onSelected: (String result) {
                setState(() {
                  _sortType = result;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Sort By:',
                  child: Text('Sort By'),
                  enabled: false,
                ),
                const PopupMenuDivider(
                  height: 1,
                ),
                const PopupMenuItem<String>(
                  value: 'Title (Ascending)',
                  child: Text('Title (Ascending)'),
                ),
                const PopupMenuItem<String>(
                  value: 'Title (Descending)',
                  child: Text('Title (Descending)'),
                ),
                const PopupMenuItem<String>(
                  value: 'Create Date (Ascending)',
                  child: Text('Create Date (Ascending)'),
                ),
                const PopupMenuItem<String>(
                  value: 'Create Date (Descending)',
                  child: Text('Create Date (Descending)'),
                ),
                const PopupMenuItem<String>(
                  value: 'Last Modified (Ascending)',
                  child: Text('Last Modified (Ascending)'),
                ),
                const PopupMenuItem<String>(
                  value: 'Last Modified (Descending)',
                  child: Text('Last Modified (Descending)'),
                ),
              ],
            )
          ],
        ),
        body: Center(
            child: FutureBuilder(
                future: provider.isInitCompleted,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      mainAxisSpacing: 40,
                      crossAxisCount: 2,
                      children: books
                          .map((b) => BookWidget.withRoute(b, '/book_overview'))
                          .toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
