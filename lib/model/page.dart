import 'package:collection/collection.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class PageModel extends BaseModel {
  static const id = 'id';
  static const bookId = 'book_id';
  static const pageNumber = 'page_num';
  static const createTime = 'createTime';
  static const lastModifiedTime = 'lastModifiedTime';

  PageModel({required String bookTableName, required DBCol bookTableIdCol})
      : super(
            cols: DBCols([
          DBCol(name: id, type: DBType.rowId()),
          DBCol(name: bookId, type: DBType.fromForeign(bookTableIdCol.type)),
          DBCol(name: pageNumber, type: DBType.int(notNull: true)),
          DBCol(name: createTime, type: DBType.int(notNull: true)),
          DBCol(name: lastModifiedTime, type: DBType.int(notNull: true)),
        ], foreignKeys: [
          DBForeignKey(
              colNames: [bookId],
              foreignTableName: bookTableName,
              foreignTableColNames: [bookTableIdCol.name]),
        ], uniqueColNames: [
          [bookId, pageNumber],
        ]));
}

class Page {
  int? id; // id from database
  int bookId; // id of book owning this page
  int pageNumber; // page number in the book
  final DateTime createTime; // create time from database
  DateTime lastModifiedTime; // last modified time from database

  Page._internal(
      {this.id,
      required this.bookId,
      required this.pageNumber,
      required this.createTime,
      required this.lastModifiedTime});

  factory Page({required int bookId, required int pageNumber}) {
    final timestamp = DateTime.now();
    return Page._internal(
        bookId: bookId,
        pageNumber: pageNumber,
        createTime: timestamp,
        lastModifiedTime: timestamp);
  }

  factory Page.fromJson(Map<String, Object?> json) {
    return Page._internal(
        id: json[PageModel.id] as int,
        bookId: json[PageModel.bookId] as int,
        pageNumber: json[PageModel.pageNumber] as int,
        createTime: DateTime.fromMillisecondsSinceEpoch(
            json[PageModel.createTime] as int),
        lastModifiedTime: DateTime.fromMillisecondsSinceEpoch(
            json[PageModel.lastModifiedTime] as int));
  }

  factory Page._copy({
    int? id,
    int? bookId,
    int? pageNumber,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required Page original,
  }) {
    return Page._internal(
        id: id ?? original.id,
        bookId: bookId ?? original.bookId,
        pageNumber: pageNumber ?? original.pageNumber,
        createTime: createTime ?? original.createTime,
        lastModifiedTime: lastModifiedTime ?? original.lastModifiedTime);
  }

  Page copy({
    int? bookId,
    int? pageNumber,
    DateTime? lastModifiedTime,
  }) {
    return Page._copy(
        bookId: bookId,
        pageNumber: pageNumber,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        PageModel.id: id,
        PageModel.bookId: bookId,
        PageModel.pageNumber: pageNumber,
        PageModel.createTime: createTime.millisecondsSinceEpoch,
        PageModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) => other is Page && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
