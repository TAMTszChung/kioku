import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/image_item_list_tile.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';

class BookListView extends StatelessWidget {
  final int id;
  const BookListView(this.id, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<BookPageProvider>();
    List<BookPage> pages = pageProvider.getAllByBookId(id);
    final itemProvider = context.watch<PageItemProvider>();
    final List<PageItem> items =
        itemProvider.getAllByPageIdList(pages.map((p) => p.id!).toList());
    final imageItems = items
        .where((item) => item.type == PageItemType.IMAGE)
        .map((item) => item.copy())
        .toList();

    if (imageItems.isEmpty) {
      return const Center(
          child: Text(
        'There is no image items in this book!\n\nTo create items, add images in book pages.',
        textAlign: TextAlign.center,
      ));
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: imageItems.map((item) => ImageItemListTile(item)).toList(),
    );
  }
}
