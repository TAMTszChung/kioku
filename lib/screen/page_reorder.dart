import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/book_page.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:provider/provider.dart';

class PageReorderScreen extends StatefulWidget {
  final int id;

  const PageReorderScreen(this.id, {Key? key}) : super(key: key);

  @override
  State<PageReorderScreen> createState() => _PageReorderScreenState();
}

class _PageReorderScreenState extends State<PageReorderScreen> {
  List<BookPage> pages = [];
  bool saving = false;

  @override
  void initState() {
    super.initState();
    pages = context
        .read<BookPageProvider>()
        .getAllByBookId(widget.id)
        .map((p) => p.copy())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Reorder'),
        actions: [
          saving
              ? const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator()))
              : TextButton(
                  onPressed: !saving
                      ? () async {
                          setState(() {
                            saving = true;
                          });

                          final copiedPages =
                              pages.map((e) => e.copy()).toList();
                          for (int i = 0; i < copiedPages.length; i++) {
                            copiedPages[i].pageNumber = i + 1;
                          }

                          //update the page order
                          await context
                              .read<BookPageProvider>()
                              .setAll(widget.id, copiedPages);

                          //update book last edit time
                          final book =
                              context.read<BookProvider>().get(widget.id);
                          await context.read<BookProvider>().update(book);

                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Save'))
        ],
      ),
      body: ReorderableListView(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 3),
        onReorder: (int oldIndex, int newIndex) {
          if (saving) return;

          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = pages.removeAt(oldIndex);
            pages.insert(newIndex, item);
          });
        },
        children: pages
            .map((page) => Padding(
                  key: Key('reorderPageID${page.id}'),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: BookPageWidget(
                    page,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
