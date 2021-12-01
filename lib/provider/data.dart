import 'package:flutter/foundation.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

abstract class DataProvider with ChangeNotifier {
  final String tableName;
  final BaseModel model;
  late Future<bool> isInitCompleted;
  @protected
  bool isTableCreated = false;

  DataProvider({
    required this.tableName,
    required this.model,
  }) {
    isInitCompleted = fetchAll();
  }

  @protected
  Future createTable() async {
    if (isTableCreated) return;
    await DBHelper.instance
        .createTable(tableName: tableName, fields: model.fields);
    isTableCreated = true;
  }

  @protected
  Future<bool> fetchAll() async {
    if (!isTableCreated) await createTable();
    return true;
    // Important: extend this function and call notifyListeners() finally
  }
}
