/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'package:collection/collection.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class BookPageProvider extends DataProvider {
  final BookProvider bookProvider;

  BookPageProvider(this.bookProvider)
      : super(
            tableName: 'Page',
            model: BookPageModel(
                bookTableName: bookProvider.tableName,
                bookTableIdCol: bookProvider.model.cols[BookModel.id]!));

  List<BookPage> _pages = [];

  List<BookPage> get pages => [..._pages];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    _pages = maps.map((json) => BookPage.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<BookPage?> insert(BookPage page) async {
    final db = await DBHelper.instance.db;
    final data = page.toJson();
    final pageNumber = data[BookPageModel.pageNumber] as int?;
    if (pageNumber == null || pageNumber < 1) {
      final bookId = data[BookPageModel.bookId] as int;
      final numPages = _pages.where((page) => page.bookId == bookId).length;
      data[BookPageModel.pageNumber] = numPages + 1;
    }
    final id = await db.insert(tableName, data);
    final insertedPage = await fetch(id);
    if (insertedPage == null) return null;
    _pages.add(insertedPage);
    notifyListeners();
    return insertedPage;
  }

  Future<BookPage?> fetch(int? id, {int? bookId, int? pageNumber}) async {
    final db = await DBHelper.instance.db;
    late final List<Map<String, Object?>> maps;
    if (id != null) {
      maps = await db
          .query(tableName, where: '${BookPageModel.id} = ?', whereArgs: [id]);
    } else {
      if (bookId == null || pageNumber == null) {
        throw ArgumentError(
            'Must provide id, or both bookId and pageNumber to fetch',
            'id, bookId, pageNumber');
      }
      maps = await db.query(tableName,
          where:
              '${BookPageModel.bookId} = ? AND ${BookPageModel.pageNumber} = ?',
          whereArgs: [bookId, pageNumber]);
    }
    if (maps.isNotEmpty) {
      return BookPage.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<BookPage?> update(BookPage pageToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = pageToUpdate.toJson();
    final id = data[BookPageModel.id] as int?;
    if (id == null) {
      throw ArgumentError('id property cannot be null', 'pageToUpdate');
    }
    data.remove(BookPageModel.id);
    data[BookPageModel.lastModifiedTime] =
        DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(tableName, data,
        where: '${BookPageModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update page with id $id');
    final updatedPage = await fetch(id);
    if (updatedPage == null) return null;
    final index = _pages.indexWhere((page) => page.id == id);
    if (index < 0) {
      _pages.add(updatedPage);
    } else {
      _pages[index] = updatedPage;
    }

    notifyListeners();
    return updatedPage;
  }

  Future<int?> delete(int id) async {
    final db = await DBHelper.instance.db;
    final count = await db
        .delete(tableName, where: '${BookPageModel.id} = ?', whereArgs: [id]);
    if (count != 1) return null;
    _pages.removeWhere((page) => page.id == id);
    notifyListeners();
    return id;
  }

  BookPage get(int? id, {int? bookId, int? pageNumber}) {
    late final BookPage page;
    if (id != null) {
      page = _pages.singleWhere((page) => page.id == id);
    } else {
      if (bookId == null || pageNumber == null) {
        throw ArgumentError(
            'Must provide id, or both bookId and pageNumber to get',
            'id, bookId, pageNumber');
      }
      page = _pages.singleWhere(
          (page) => page.bookId == bookId && page.pageNumber == pageNumber);
    }
    return page;
  }

  List<BookPage> getAllByBookId(int bookId) {
    return _pages
        .where((page) => page.bookId == bookId)
        .toList()
        .sortedBy<num>((page) => page.pageNumber);
  }

  Future<List<BookPage>> setAll(int bookId, List<BookPage> listToSet) async {
    if (listToSet.any((item) => item.bookId != bookId)) {
      throw ArgumentError('All pages must have identical bookId', 'listToSet');
    }
    final db = await DBHelper.instance.db;
    final batch = db.batch();
    final pagesToDelete = _pages.where((oldPage) =>
        oldPage.bookId == bookId &&
        listToSet.singleWhereOrNull((page) => page.id == oldPage.id) == null);
    for (var page in pagesToDelete) {
      batch.delete(tableName,
          where: '${BookPageModel.id} = ?', whereArgs: [page.id]);
    }
    final pagesToUpdate = listToSet.where((page) {
      if (page.id == null) return false;
      final oldPage = _pages.singleWhere((oldPage) => oldPage.id == page.id);
      return page != oldPage;
    });
    for (var page in pagesToUpdate) {
      final data = page.toJson();
      final id = data[BookPageModel.id] as int;
      data.remove(BookPageModel.id);
      data[BookPageModel.lastModifiedTime] =
          DateTime.now().millisecondsSinceEpoch;
      batch.update(tableName, data,
          where: '${BookPageModel.id} = ?', whereArgs: [id]);
    }
    final pagesToInsert = listToSet
        .where((page) => page.id == null)
        .sortedBy<DateTime>((page) => page.lastModifiedTime);
    for (var page in pagesToInsert) {
      final data = page.toJson();
      final pageNumber = data[BookPageModel.pageNumber] as int?;
      if (pageNumber == null || pageNumber < 1) {
        // IMPORTANT: for each bookId, there must be at most 1 page with id null
        final bookId = data[BookPageModel.bookId] as int;
        final numPages = _pages.where((page) => page.bookId == bookId).length;
        data[BookPageModel.pageNumber] = numPages + 1;
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      data[BookPageModel.lastModifiedTime] = timestamp;
      data[BookPageModel.createTime] = timestamp;
      batch.insert(tableName, data);
    }
    await batch.commit(continueOnError: true, noResult: true);
    await fetchAll();
    return pages;
  }
}
