import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBType {
  static const _textType = 'TEXT';
  static const _blobType = 'BLOB';
  static const _intType = 'INTEGER';
  static const _notNull = 'NOT NULL';
  static const _primaryKey = 'PRIMARY KEY';
  static const _autoIncrement = 'AUTOINCREMENT';

  final String type;
  final bool notNull;
  final bool primaryKey;
  final bool autoIncrement;

  DBType._internal(
      {required this.type,
      this.notNull = false,
      this.primaryKey = false,
      this.autoIncrement = false});

  DBType.rowId() : this.int(primaryKey: true, autoIncrement: true);

  DBType.fromForeign(DBType foreignType)
      : this._internal(type: foreignType.type);

  DBType.text({bool notNull = false, bool primaryKey = false})
      : this._internal(
            type: _textType, notNull: notNull, primaryKey: primaryKey);

  DBType.blob({bool notNull = false, bool primaryKey = false})
      : this._internal(
            type: _blobType, notNull: notNull, primaryKey: primaryKey);

  DBType.int(
      {bool notNull = false,
      bool primaryKey = false,
      bool autoIncrement = false})
      : this._internal(
            type: _intType,
            notNull: notNull,
            primaryKey: primaryKey,
            autoIncrement: autoIncrement);

  @override
  String toString() {
    String str = type;
    if (primaryKey) {
      str += ' $_primaryKey';
    } else if (notNull) {
      str += ' $_notNull';
    }
    if (type == _intType && autoIncrement) {
      str += ' $_autoIncrement';
    }
    return str;
  }
}

class DBForeignKey {
  static const _prefix = 'FOREIGN KEY';
  static const _suffix = 'REFERENCES';

  static const _onUpdate = 'ON UPDATE';
  static const _onDelete = 'ON DELETE';

  static const cascade = 'CASCADE';
  static const noAction = 'NO ACTION';

  final List<String> colNames;
  final String foreignTableName;
  final List<String> foreignTableColNames;
  final String onUpdateAction;
  final String onDeleteAction;

  DBForeignKey(
      {required this.colNames,
      required this.foreignTableName,
      this.foreignTableColNames = const [],
      this.onDeleteAction = cascade,
      this.onUpdateAction = noAction});

  @override
  String toString() {
    String str = '$_prefix(${colNames.join(', ')}) $_suffix $foreignTableName';
    if (foreignTableColNames.isNotEmpty) {
      str += '(${foreignTableColNames.join(', ')})';
    }
    str += ' $_onUpdate $onUpdateAction $_onDelete $onDeleteAction';
    return str;
  }
}

class DBCol {
  final String name;
  final DBType type;

  DBCol({required this.name, required this.type});

  @override
  String toString() {
    return '$name $type';
  }
}

class DBCols {
  late final Map<String, DBCol> cols;
  late final List<DBForeignKey> foreignKeyGroups;
  late final List<List<String>> uniqueColsGroups;
  DBCols(List<DBCol> cols,
      {this.foreignKeyGroups = const [],
      List<List<int>> uniqueIndexesGroups = const []}) {
    this.cols = Map<String, DBCol>.fromIterable(cols, key: (col) => col.name);
    uniqueColsGroups = uniqueIndexesGroups
        .map((group) =>
            group.map((index) => cols[index].name).toList(growable: false))
        .toList(growable: false);
  }

  DBCol? operator [](String name) => cols[name];

  @override
  String toString() {
    String str = '';
    str += cols.values.map((field) => field.toString()).join(', ');
    final foreignKeysStr =
        foreignKeyGroups.map((group) => group.toString()).join(', ');
    if (foreignKeysStr.isNotEmpty) {
      str += ', $foreignKeysStr';
    }
    final uniqueColsStr = uniqueColsGroups
        .map((group) => group.join(', '))
        .map((groupStr) => 'UNIQUE($groupStr)')
        .join(', ');
    if (uniqueColsStr.isNotEmpty) {
      str += ', $uniqueColsStr';
    }
    return str;
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
    return await sql.openDatabase(dbPath,
        version: _dbVersion, onConfigure: _onConfigure);
  }

  Future _onConfigure(sql.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future createTable({required String tableName, required DBCols cols}) async {
    final db = await this.db;
    String stmt = 'CREATE TABLE IF NOT EXISTS $tableName ($cols);';
    await db.execute(stmt);
  }
}
