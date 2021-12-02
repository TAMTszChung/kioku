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
            cols: DBCols([
          DBCol(name: id, type: DBType.rowId()),
          DBCol(name: title, type: DBType.text(notNull: true)),
          DBCol(name: color, type: DBType.int(notNull: true)),
          DBCol(name: cover, type: DBType.blob()),
          DBCol(name: createTime, type: DBType.int(notNull: true)),
          DBCol(name: lastModifiedTime, type: DBType.int(notNull: true)),
        ]));
}

class Book {
  int? id; // id from database
  late String title; // title
  late Color color; // color of cover
  String? cover; // image of cover in base64
  late final DateTime createTime; // create time from database
  late DateTime lastModifiedTime; // last modified time from database

  Book({this.title = 'Untitled', this.color = Colors.grey}) {
    final timestamp = DateTime.now();
    createTime = timestamp;
    lastModifiedTime = timestamp;
  }

  Book.fromJson(Map<String, Object?> json) {
    id = json[BookModel.id] as int;
    title = json[BookModel.title] as String;
    color = Color(json[BookModel.color] as int);
    cover = json[BookModel.cover] as String?;
    createTime =
        DateTime.fromMillisecondsSinceEpoch(json[BookModel.createTime] as int);
    lastModifiedTime = DateTime.fromMillisecondsSinceEpoch(
        json[BookModel.lastModifiedTime] as int);
  }

  Book._copy({
    int? id,
    String? title,
    Color? color,
    String? cover,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required Book original,
  }) {
    this.id = id ?? original.id;
    this.title = title ?? original.title;
    this.color = color ?? original.color;
    this.cover = cover ?? original.cover;
    this.createTime = createTime ?? original.createTime;
    this.lastModifiedTime = lastModifiedTime ?? original.lastModifiedTime;
  }

  Book copy({
    String? title,
    Color? color,
    String? cover,
    DateTime? lastModifiedTime,
  }) {
    return Book._copy(
        title: title,
        color: color,
        cover: cover,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        BookModel.id: id,
        BookModel.title: title,
        BookModel.color: color.value,
        BookModel.cover: cover,
        BookModel.createTime: createTime.millisecondsSinceEpoch,
        BookModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };
}
