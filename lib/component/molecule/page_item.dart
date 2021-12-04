import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kioku/model/page_item.dart';

typedef TextChangeCallback = void Function(String?);

class PageItemWidget extends StatefulWidget {
  final PageItem item;
  final TextChangeCallback onTextChange;

  const PageItemWidget(this.item, this.onTextChange, {Key? key})
      : super(key: key);

  @override
  State<PageItemWidget> createState() => _PageItemWidgetState();
}

class _PageItemWidgetState extends State<PageItemWidget> {
  late bool underline = widget.item.attributes['underline'] == 'true';
  late bool italic = widget.item.attributes['italic'] == 'true';
  late bool bold = widget.item.attributes['bold'] == 'true';
  late String fontFamily = widget.item.attributes['fontFamily'] != null
      ? widget.item.attributes['fontFamily']!
      : 'Merriweather';
  late int fontSize = widget.item.attributes['fontSize'] != null
      ? int.parse(widget.item.attributes['fontSize']!)
      : 20;
  late Color fontColor = widget.item.attributes['color'] != null
      ? Color(int.parse(widget.item.attributes['color']!, radix: 16))
      : Colors.black;
  late Color highlightColor = widget.item.attributes['highlightColor'] != null
      ? Color(int.parse(widget.item.attributes['highlightColor']!, radix: 16))
      : Colors.transparent;
  late Color backgroundColor = widget.item.attributes['backgroundColor'] != null
      ? Color(int.parse(widget.item.attributes['backgroundColor']!, radix: 16))
      : Colors.transparent;

  TextStyle itemStyle() {
    switch (fontFamily) {
      case 'Merriweather':
      default:
        return GoogleFonts.merriweather(
          fontStyle: italic ? FontStyle.italic : null,
          decoration: underline ? TextDecoration.underline : null,
          fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          color: fontColor,
          backgroundColor: highlightColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.type == PageItemType.IMAGE) {
      return Image.memory(widget.item.data);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Text(utf8.decode(widget.item.data), style: itemStyle()),
      );
    }
  }
}
