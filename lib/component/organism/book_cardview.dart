/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/image_item_card.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';

class BookCardView extends StatelessWidget {
  final int id;
  final String category;

  const BookCardView(this.id, this.category, {Key? key}) : super(key: key);

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

    if (category != 'All') {
      imageItems.removeWhere((item) => !item.categories.contains(category));
    }

    if (imageItems.isEmpty) {
      return const Center(
          child: Text(
        'There is no image items in this book or category!\nTry adding images in pages!',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      ));
    }
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 40,
      crossAxisCount: 2,
      children: imageItems.map((item) => ImageItemCard(item)).toList(),
    );
  }
}
