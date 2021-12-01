import 'dart:ui';

import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class BookModel extends BaseModel {
  BookModel()
      : super(fields: [
          DBField(name: 'id', type: DBType.id()),
          DBField(name: 'title', type: DBType.text(notNull: true)),
          DBField(name: 'color', type: DBType.int(notNull: true)),
          DBField(name: 'cover', type: DBType.blob()),
          DBField(name: 'createTime', type: DBType.int(notNull: true)),
          DBField(name: 'lastModifiedTime', type: DBType.int(notNull: true)),
        ]);
}

class Book {
  int? id; // id from database
  late String title; // title
  late Color color; // color of cover
  String? cover; // image of cover in base64
  DateTime? createTime; // create time from database
  DateTime? lastModifiedTime; // last modified time from database

  Book({this.title = "Untitled", Color? color}) {
    if (color == null) {
      // TODO: generate a random color
    }
    this.color = color!;
  }

  Book._copy({
    required this.id,
    DateTime? createTime,
    required Book original,
  }) {
    title = original.title;
    color = original.color;
    cover = original.cover;
    this.createTime = createTime ?? original.createTime;
    lastModifiedTime = createTime ?? original.lastModifiedTime;
  }

  Book copy({required id, DateTime? copyTime}) {
    return Book._copy(id: id, createTime: copyTime, original: this);
  }

  Book update({
    String? title,
    Color? color,
    String? cover,
    DateTime? modified,
  }) {
    if (title != null) this.title = title;
    if (color != null) this.color = color;
    if (cover != null) this.cover = cover;
    if (modified != null) lastModifiedTime = modified;
    return this;
  }
}
