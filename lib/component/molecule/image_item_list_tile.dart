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
          //TODO: navigate to detail page;
          Navigator.pushNamed(context, '/item_detail', arguments: item.id);
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
                ? Image.memory(item.data)
                : null,
            title: Text(item.name ?? 'Untitled'),
            subtitle: item.categories != null
                ? Text(item.categories!.join(', '))
                : const Text(''),
          ),
        ),
      ), //declare your widget here
    );
  }
}
