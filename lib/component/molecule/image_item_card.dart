/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:flutter/material.dart';
import 'package:kioku/model/page_item.dart';

class ImageItemCard extends StatelessWidget {
  final PageItem item;

  const ImageItemCard(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8,
        child: InkWell(
          splashColor: Colors.blue,
          onTap: () {
            Navigator.pushNamed(context, '/item_detail', arguments: item);
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            color:
                item.type != PageItemType.IMAGE ? Colors.blueGrey[800] : null,
            decoration: BoxDecoration(
              image: item.type == PageItemType.IMAGE
                  ? DecorationImage(
                      image: MemoryImage(item.data),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      constraints:
                          BoxConstraints(maxHeight: constraints.maxHeight / 2),
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: Text(item.name ?? 'Untitled'),
                            subtitle: Text(item.categories.join(', ')),
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ),
      ),
    );
  }
}
