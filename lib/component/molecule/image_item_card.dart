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
        elevation: 8,
        child: InkWell(
          splashColor: Colors.blue,
          onTap: () {
            Navigator.pushNamed(context, '/item_detail', arguments: item);
          },
          child: Container(
            color:
                item.type != PageItemType.IMAGE ? Colors.blueGrey[800] : null,
            decoration: BoxDecoration(
              image: item.type == PageItemType.IMAGE
                  ? DecorationImage(
                      image: MemoryImage(item.data),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white60,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text(item.name ?? 'Untitled'),
                      subtitle: item.categories != null
                          ? Text(item.categories.join(', '))
                          : const Text(''),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
