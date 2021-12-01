import 'package:kioku/model/book.dart';
import 'package:kioku/provider/data.dart';
import 'package:kioku/service/database.dart';

class BookProvider extends DataProvider {
  BookProvider() : super(tableName: 'Book', model: BookModel());

  List<Book> _books = [];

  List<Book> get books => [..._books];

  @override
  Future<bool> fetch() async {
    super.fetch();

    final db = await DBHelper.instance.db;
    final maps = await db.query(tableName);
    // _books = [
    //   Book(title: 'Alpha', color: Colors.blue),
    //   Book(title: 'Beta', color: Colors.yellow),
    // ];
    _books = maps.map((json) => Book.fromJson(json)).toList();
    notifyListeners();
    return true;
  }

  Future<Book?> insert(Book book) async {
    final db = await DBHelper.instance.db;
    final data = book.toJson();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    data[BookModel.createTime] = timestamp;
    data[BookModel.lastModifiedTime] = timestamp;
    final id = await db.insert(tableName, data);
    final insertedBook = await get(id);
    if (insertedBook == null) return null;
    _books.add(insertedBook);
    notifyListeners();
    return insertedBook;
  }

  Future<Book?> get(int id) async {
    final db = await DBHelper.instance.db;
    final maps = await db
        .query(tableName, where: '${BookModel.id} = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    } else {
      return null;
    }
  }
}
