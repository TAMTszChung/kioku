import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBType {
  static const _idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const _textType = 'TEXT';
  static const _blobType = 'BLOB';
  static const _intType = 'INTEGER';
  static const _notNull = 'NOT NULL';

  late final String value;

  DBType._internal({required this.value, bool notNull = false}) {
    if (notNull) value += ' $_notNull';
  }

  DBType.id() {
    DBType._internal(value: _idType);
  }

  DBType.text({bool notNull = false}) {
    DBType._internal(value: _textType, notNull: notNull);
  }

  DBType.blob({bool notNull = false}) {
    DBType._internal(value: _blobType, notNull: notNull);
  }

  DBType.int({bool notNull = false}) {
    DBType._internal(value: _intType, notNull: notNull);
  }
}

class DBField {
  final String name;
  final DBType type;

  DBField({required this.name, required this.type});
}

class DBHelper {
  static const _dbName = 'kioku.db';
  static const _dbVersion = 1;

  static String getCreateTableStmt(
      {required String tableName, required List<DBField> fields}) {
    String stmt = 'CREATE TABLE $tableName IF NOT EXISTS (';
    for (DBField field in fields) {
      // TODO: gen the fields
    }
    return stmt;
  }

  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static sql.Database? _db;
  Future<sql.Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<sql.Database> _initDB() async {
    String dbPath = await sql.getDatabasesPath();
    dbPath = path.join(dbPath, _dbName);
    return await sql.openDatabase(dbPath, version: _dbVersion);
  }
}
