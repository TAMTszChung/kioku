import 'package:collection/collection.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class BookPageModel extends BaseModel {
  static const id = 'id';
  static const bookId = 'book_id';
  static const pageNumber = 'page_num';
  static const thumbnail = 'thumbnail';
  static const createTime = 'createTime';
  static const lastModifiedTime = 'lastModifiedTime';

  BookPageModel({required String bookTableName, required DBCol bookTableIdCol})
      : super(
            cols: DBCols([
          DBCol(name: id, type: DBType.rowId()),
          DBCol(name: bookId, type: DBType.fromForeign(bookTableIdCol.type)),
          DBCol(name: pageNumber, type: DBType.int(notNull: true)),
          DBCol(name: thumbnail, type: DBType.blob()),
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

class BookPage {
  int? id; // id from database
  int bookId; // id of book owning this page
  int pageNumber; // page number in the book
  String? thumbnail; // thumbnail (snapshot) of the items
  final DateTime createTime; // create time from database
  DateTime lastModifiedTime; // last modified time from database

  BookPage._internal(
      {this.id,
      required this.bookId,
      required this.pageNumber,
      this.thumbnail,
      required this.createTime,
      required this.lastModifiedTime});

  factory BookPage({required int bookId, int pageNumber = -1}) {
    final timestamp = DateTime.now();
    return BookPage._internal(
        bookId: bookId,
        pageNumber: pageNumber,
        createTime: timestamp,
        lastModifiedTime: timestamp);
  }

  factory BookPage.fromJson(Map<String, Object?> json) {
    return BookPage._internal(
        id: json[BookPageModel.id] as int,
        bookId: json[BookPageModel.bookId] as int,
        pageNumber: json[BookPageModel.pageNumber] as int,
        thumbnail: json[BookPageModel.thumbnail] as String?,
        createTime: DateTime.fromMillisecondsSinceEpoch(
            json[BookPageModel.createTime] as int),
        lastModifiedTime: DateTime.fromMillisecondsSinceEpoch(
            json[BookPageModel.lastModifiedTime] as int));
  }

  factory BookPage._copy({
    int? id,
    int? bookId,
    int? pageNumber,
    String? thumbnail,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required BookPage original,
  }) {
    return BookPage._internal(
        id: id ?? original.id,
        bookId: bookId ?? original.bookId,
        pageNumber: pageNumber ?? original.pageNumber,
        thumbnail: thumbnail ?? original.thumbnail,
        createTime: createTime ?? original.createTime,
        lastModifiedTime: lastModifiedTime ?? original.lastModifiedTime);
  }

  BookPage copy({
    int? bookId,
    int? pageNumber,
    String? thumbnail,
    DateTime? lastModifiedTime,
  }) {
    return BookPage._copy(
        bookId: bookId,
        pageNumber: pageNumber,
        thumbnail: thumbnail,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        BookPageModel.id: id,
        BookPageModel.bookId: bookId,
        BookPageModel.pageNumber: pageNumber,
        BookPageModel.createTime: createTime.millisecondsSinceEpoch,
        BookPageModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) =>
      other is BookPage && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
