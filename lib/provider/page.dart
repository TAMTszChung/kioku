import 'package:kioku/model/book.dart';
import 'package:kioku/model/page.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class PageProvider extends DataProvider {
  final BookProvider bookProvider;

  PageProvider(this.bookProvider)
      : super(
            tableName: 'Page',
            model: PageModel(
                bookTableName: bookProvider.tableName,
                bookTableIdCol: bookProvider.model.cols[BookModel.id]!));

  List<Page> _pages = [];

  List<Page> get pages => [..._pages];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    _pages = maps.map((json) => Page.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<Page?> insert(Page page) async {
    final db = await DBHelper.instance.db;
    final data = page.toJson();
    final id = await db.insert(tableName, data);
    final insertedPage = await fetch(id);
    if (insertedPage == null) return null;
    _pages.add(insertedPage);
    notifyListeners();
    return insertedPage;
  }

  Future<Page?> fetch(int? id, {int? bookId, int? pageNumber}) async {
    final db = await DBHelper.instance.db;
    late final List<Map<String, Object?>> maps;
    if (id != null) {
      maps = await db
          .query(tableName, where: '${PageModel.id} = ?', whereArgs: [id]);
    } else {
      if (bookId == null || pageNumber == null) {
        throw Exception(
            'Must provide id, or both bookId and pageNumber to fetch');
      }
      maps = await db.query(tableName,
          where: '${PageModel.bookId} = ? AND ${PageModel.pageNumber} = ?',
          whereArgs: [bookId, pageNumber]);
    }
    if (maps.isNotEmpty) {
      return Page.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Page?> update(Page pageToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = pageToUpdate.toJson();
    final id = data[PageModel.id] as int?;
    if (id == null) throw Exception('id property cannot be null');
    data.remove(PageModel.id);
    final count = await db
        .update(tableName, data, where: '${PageModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update page with id $id');
    final updatedPage = await fetch(id);
    if (updatedPage == null) return null;
    var index = _pages.indexWhere((page) => page.id == id);
    if (index < 0) {
      _pages.add(updatedPage);
    } else {
      _pages[index] = updatedPage;
    }

    notifyListeners();
    return updatedPage;
  }

  Page get(int? id, {int? bookId, int? pageNumber}) {
    late final Page page;
    if (id != null) {
      page = _pages.singleWhere((page) => page.id == id);
    } else {
      if (bookId == null || pageNumber == null) {
        throw Exception(
            'Must provide id, or both bookId and pageNumber to get');
      }
      page = _pages.singleWhere(
          (page) => page.bookId == bookId && page.pageNumber == pageNumber);
    }
    return page;
  }
}
