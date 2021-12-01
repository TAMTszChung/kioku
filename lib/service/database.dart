import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBType {
  static const _idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const _textType = 'TEXT';
  static const _blobType = 'BLOB';
  static const _intType = 'INTEGER';
  static const _notNull = 'NOT NULL';

  final String type;
  final bool notNull;

  DBType._internal({required this.type, this.notNull = false});

  DBType.id() : this._internal(type: _idType);

  DBType.text({bool notNull = false})
      : this._internal(type: _textType, notNull: notNull);

  DBType.blob({bool notNull = false})
      : this._internal(type: _blobType, notNull: notNull);

  DBType.int({bool notNull = false})
      : this._internal(type: _intType, notNull: notNull);

  @override
  String toString() => type + (notNull ? ' $_notNull' : '');
}

class DBField {
  final String name;
  final DBType type;

  DBField({required this.name, required this.type});

  @override
  String toString() => '$name $type';
}

class DBFields {
  late final Map<String, DBField> fields;
  DBFields(List<DBField> fields) {
    this.fields =
        Map<String, DBField>.fromIterable(fields, key: (field) => field.name);
  }

  DBField? operator [](String name) => fields[name];

  @override
  String toString() {
    const delimiter = ', ';
    String result = '';
    for (var field in fields.values) {
      result += field.toString();
      if (field != fields.values.last) result += delimiter;
    }
    return result;
  }
}

class DBHelper {
  static const _dbName = 'kioku.db';
  static const _dbVersion = 1;

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
    // TODO: remove this delete statement in production
    await sql.deleteDatabase(dbPath);
    return await sql.openDatabase(dbPath, version: _dbVersion);
  }

  Future createTable(
      {required String tableName, required DBFields fields}) async {
    final db = await this.db;
    String stmt = 'CREATE TABLE IF NOT EXISTS $tableName ($fields);';
    await db.execute(stmt);
  }
}
