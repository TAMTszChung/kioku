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
        ], foreignKeyGroups: [
          DBForeignKey(
              colNames: [bookId],
              foreignTableName: bookTableName,
              foreignTableColNames: [bookTableIdCol.name]),
        ], uniqueIndexesGroups: [
          [1, 2]
        ]));
}

class Page {
  int? id; // id from database
  late int bookId; // id of book owning this page
  late int pageNumber; // page number in the book
  late final DateTime createTime; // create time from database
  late DateTime lastModifiedTime; // last modified time from database

  Page({required this.bookId, required this.pageNumber}) {
    final timestamp = DateTime.now();
    createTime = timestamp;
    lastModifiedTime = timestamp;
  }

  Page.fromJson(Map<String, Object?> json) {
    id = json[PageModel.id] as int;
    bookId = json[PageModel.bookId] as int;
    pageNumber = json[PageModel.pageNumber] as int;
    createTime =
        DateTime.fromMillisecondsSinceEpoch(json[PageModel.createTime] as int);
    lastModifiedTime = DateTime.fromMillisecondsSinceEpoch(
        json[PageModel.lastModifiedTime] as int);
  }

  Page._copy({
    int? id,
    int? bookId,
    int? pageNumber,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required Page original,
  }) {
    this.id = id ?? original.id;
    this.bookId = bookId ?? original.bookId;
    this.pageNumber = pageNumber ?? original.pageNumber;
    this.createTime = createTime ?? original.createTime;
    this.lastModifiedTime = lastModifiedTime ?? original.lastModifiedTime;
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
}
