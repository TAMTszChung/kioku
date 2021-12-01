import 'package:flutter/material.dart';
import 'package:kioku/component/book.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final String title = "Kioku";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sortType = "Title";

  void sortBook(List<Book> list, String type) {
    setState(() {
      switch (type) {
        case "Title":
          list.sort((a, b) => a.title.compareTo(b.title));
          break;
        case "Date":
          list.sort((a, b) => b.title.compareTo(a.title));
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
              onPressed: () {
                provider.insert(Book());
              },
              icon: const Icon(Icons.add),
              color: Colors.black,
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.sort,
                color: Colors.black,
              ),
              onSelected: (String result) {
                setState(() {
                  _sortType = result;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: "Sort By:",
                  child: Text('Sort By'),
                  enabled: false,
                ),
                const PopupMenuDivider(
                  height: 1,
                ),
                const PopupMenuItem<String>(
                  value: "Title (",
                  child: Text('Title'),
                ),
                const PopupMenuItem<String>(
                  value: "Date",
                  child: Text('Date'),
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
                      children: books.map((b) => BookWidget(b)).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
