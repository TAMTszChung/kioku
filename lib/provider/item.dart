import 'package:kioku/model/item.dart';
import 'package:kioku/model/page.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/provider/page.dart';
import 'package:kioku/service/database.dart';

class ItemProvider extends DataProvider {
  final PageProvider pageProvider;

  ItemProvider(this.pageProvider)
      : super(
            tableName: 'Item',
            model: ItemModel(
                pageTableName: pageProvider.tableName,
                pageTableIdCol: pageProvider.model.cols[PageModel.id]!));

  List<Item> _items = [];

  List<Item> get items => [..._items];

  @override
  Future<bool> fetchAll() async {
    super.fetchAll();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    _items = maps.map((json) => Item.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<Item?> insert(Item item) async {
    final db = await DBHelper.instance.db;
    final data = item.toJson();
    final id = await db.insert(tableName, data);
    final insertedItem = await fetch(id);
    if (insertedItem == null) return null;
    _items.add(insertedItem);
    notifyListeners();
    return insertedItem;
  }

  Future<Item?> fetch(int id) async {
    final db = await DBHelper.instance.db;
    late final List<Map<String, Object?>> maps;
    maps = await db
        .query(tableName, where: '${ItemModel.id} = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Item.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Item?> update(Item itemToUpdate) async {
    final db = await DBHelper.instance.db;
    final data = itemToUpdate.toJson();
    final id = data[ItemModel.id] as int?;
    if (id == null) {
      throw ArgumentError('id property cannot be null', 'itemToUpdate');
    }
    data.remove(ItemModel.id);
    data[ItemModel.lastModifiedTime] = DateTime.now().millisecondsSinceEpoch;
    final count = await db
        .update(tableName, data, where: '${ItemModel.id} = ?', whereArgs: [id]);
    if (count != 1) throw Exception('Cannot update item with id $id');
    final updatedItem = await fetch(id);
    if (updatedItem == null) return null;
    var index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      _items.add(updatedItem);
    } else {
      _items[index] = updatedItem;
    }

    notifyListeners();
    return updatedItem;
  }

  Item get(int id) {
    return _items.singleWhere((page) => page.id == id);
  }
}
