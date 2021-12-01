import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class BookModel extends BaseModel {
  static const id = 'id';
  static const title = 'title';
  static const color = 'color';
  static const cover = 'cover';
  static const createTime = 'createTime';
  static const lastModifiedTime = 'lastModifiedTime';

  BookModel()
      : super(
            fields: DBFields([
          DBField(name: id, type: DBType.id()),
          DBField(name: title, type: DBType.text(notNull: true)),
          DBField(name: color, type: DBType.int(notNull: true)),
          DBField(name: cover, type: DBType.blob()),
          DBField(name: createTime, type: DBType.int(notNull: true)),
          DBField(name: lastModifiedTime, type: DBType.int(notNull: true)),
        ]));
}

class Book {
  int? id; // id from database
  late String title; // title
  late Color color; // color of cover
  String? cover; // image of cover in base64
  DateTime? createTime; // create time from database
  DateTime? lastModifiedTime; // last modified time from database

  Book({this.title = "Untitled", this.color = Colors.grey});

  Book.fromJson(Map<String, Object?> json) {
    id = json[BookModel.id] as int?;
    title = json[BookModel.title] as String;
    color = Color(json[BookModel.color] as int);
    cover = json[BookModel.cover] as String?;
    createTime =
        DateTime.fromMillisecondsSinceEpoch(json[BookModel.createTime] as int);
    lastModifiedTime = DateTime.fromMillisecondsSinceEpoch(
        json[BookModel.lastModifiedTime] as int);
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

  Map<String, Object?> toJson() => {
        BookModel.id: id,
        BookModel.title: title,
        BookModel.color: color.value,
        BookModel.cover: cover,
        BookModel.createTime: createTime?.millisecondsSinceEpoch,
        BookModel.lastModifiedTime: lastModifiedTime?.millisecondsSinceEpoch,
      };
}
