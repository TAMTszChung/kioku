/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kioku/model/page_item.dart';

typedef TextChangeCallback = void Function(String?);

class PageItemWidget extends StatelessWidget {
  final PageItem item;
  final TextChangeCallback onTextChange;

  const PageItemWidget(this.item, this.onTextChange, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fontFamily = item.attributes['fontFamily'] != null
        ? item.attributes['fontFamily']!
        : 'Merriweather';
    double fontSize = item.attributes['fontSize'] != null
        ? double.parse(item.attributes['fontSize']!)
        : 12.0;
    Color fontColor = item.attributes['color'] != null
        ? Color(int.parse(item.attributes['color']!, radix: 16))
        : Colors.black;
    Color highlightColor = item.attributes['highlightColor'] != null
        ? Color(int.parse(item.attributes['highlightColor']!, radix: 16))
        : Colors.transparent;
    Color backgroundColor = item.attributes['backgroundColor'] != null
        ? Color(int.parse(item.attributes['backgroundColor']!, radix: 16))
        : Colors.transparent;

    TextStyle itemStyle() {
      return GoogleFonts.getFont(
        fontFamily,
        fontStyle:
            item.attributes['italic'] == 'true' ? FontStyle.italic : null,
        decoration: item.attributes['underline'] == 'true'
            ? TextDecoration.underline
            : null,
        fontWeight: item.attributes['bold'] == 'true'
            ? FontWeight.bold
            : FontWeight.normal,
        color: fontColor,
        backgroundColor: highlightColor,
        fontSize: fontSize,
      );
    }

    if (item.type == PageItemType.IMAGE) {
      return Image.memory(item.data);
    } else {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Center(child: Text(utf8.decode(item.data), style: itemStyle())),
      );
    }
  }
}
