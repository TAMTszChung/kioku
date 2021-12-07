/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

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
    return WillPopScope(
        //-------------------------- Perform Exit Check -----------------------
        onWillPop: () async {
          final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Leave Reorder Page'),
                  content: const Text(
                      'Leaving this page will discard all the changes.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                );
              });

          if (res != null) {
            return true;
          }
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Page Reorder'),
            actions: [
              saving
                  ? const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator()))
                  : IconButton(
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
                      icon: const Icon(Icons.save))
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: BookPageWidget(
                        page,
                      ),
                    ))
                .toList(),
          ),
        ));
  }
}
