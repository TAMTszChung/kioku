import 'package:collection/collection.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class PageItemProvider extends DataProvider {
  final BookPageProvider pageProvider;

  PageItemProvider(this.pageProvider)
      : super(
            tableName: 'Item',
            model: PageItemModel(
                pageTableName: pageProvider.tableName,
                pageTableIdCol: pageProvider.model.cols[BookPageModel.id]!));

  List<PageItem> _items = [];

  List<PageItem> get items => [..._items];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    _items = maps.map((json) => PageItem.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<PageItem?> insert(PageItem item) async {
    final db = await DBHelper.instance.db;
    final data = item.toJson();
    final id = await db.insert(tableName, data);
    final insertedItem = await fetch(id);
    if (insertedItem == null) return null;
    _items.add(insertedItem);
    notifyListeners();
    return insertedItem;
  }

  Future<PageItem?> fetch(int id) async {
    final db = await DBHelper.instance.db;
    late final List<Map<String, Object?>> maps;
    maps = await db
        .query(tableName, where: '${PageItemModel.id} = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return PageItem.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<PageItem?> update(PageItem itemToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = itemToUpdate.toJson();
    final id = data[PageItemModel.id] as int?;
    if (id == null) {
      throw ArgumentError('id property cannot be null', 'itemToUpdate');
    }
    data.remove(PageItemModel.id);
    data[PageItemModel.lastModifiedTime] =
        DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(tableName, data,
        where: '${PageItemModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update item with id $id');
    final updatedItem = await fetch(id);
    if (updatedItem == null) return null;
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      _items.add(updatedItem);
    } else {
      _items[index] = updatedItem;
    }

    notifyListeners();
    return updatedItem;
  }

  PageItem get(int id) {
    return _items.singleWhere((page) => page.id == id);
  }

  List<PageItem> getAllByPageId(int pageId) {
    return _items
        .where((item) => item.pageId == pageId)
        .toList()
        .sortedBy<num>((item) => item.zIndex);
  }

  List<PageItem> getAllByPageIdList(List<int> pageIds) {
    return _items
        .where((item) => pageIds.contains(item.pageId))
        .toList()
        .sorted((a, b) {
      if (a.pageId != b.pageId) return a.pageId.compareTo(b.pageId);
      return a.zIndex.compareTo(b.zIndex);
    });
  }

  Future<List<PageItem>> setAll(List<PageItem> listToSet) async {
    final db = await DBHelper.instance.db;
    final batch = db.batch();
    final itemsToUpdate = listToSet.where((item) {
      if (item.id == null) return false;
      final oldItem = _items.singleWhere((oldItem) => oldItem.id == item.id);
      return item != oldItem;
    });
    for (var item in itemsToUpdate) {
      final data = item.toJson();
      final id = data[PageItemModel.id] as int;
      data.remove(PageItemModel.id);
      data[PageItemModel.lastModifiedTime] =
          DateTime.now().millisecondsSinceEpoch;
      batch.update(tableName, data,
          where: '${PageItemModel.id} = ?', whereArgs: [id]);
    }
    final itemsToInsert = listToSet
        .where((item) => item.id == null)
        .sortedBy<DateTime>((item) => item.lastModifiedTime);
    for (var item in itemsToInsert) {
      final data = item.toJson();
      final zIndex = data[PageItemModel.zIndex] as int;
      if (zIndex < 0) {
        // IMPORTANT: for each pageId, there must be at most 1 item with zIndex < 0
        final pageId = data[PageItemModel.pageId] as int;
        final numItems = _items.where((item) => item.pageId == pageId).length;
        data[PageItemModel.zIndex] = numItems + 1;
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      data[PageItemModel.lastModifiedTime] = timestamp;
      data[PageItemModel.createTime] = timestamp;
      batch.insert(tableName, data);
    }
    await batch.commit(continueOnError: true, noResult: true);
    await fetchAll();
    return items;
  }
}
