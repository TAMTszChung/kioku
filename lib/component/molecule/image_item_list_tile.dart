/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:flutter/material.dart';
import 'package:kioku/model/page_item.dart';

class ImageItemListTile extends StatelessWidget {
  final PageItem item;

  const ImageItemListTile(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, '/item_detail', arguments: item);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            leading: item.type == PageItemType.IMAGE
                ? AspectRatio(
                    aspectRatio: 1,
                    child: Image.memory(item.data),
                  )
                : null,
            title: Text(item.name ?? 'Untitled'),
            subtitle: Text(item.categories.join(', ')),
          ),
        ),
      ), //declare your widget here
    );
  }
}
