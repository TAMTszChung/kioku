import 'package:flutter/foundation.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

abstract class DataProvider with ChangeNotifier {
  final String tableName;
  final BaseModel model;
  @protected
  bool isTableCreated = false;

  DataProvider({
    required this.tableName,
    required this.model,
  }) {
    fetch();
  }

  @protected
  Future createTable() async {
    if (isTableCreated) return;
    await DBHelper.instance
        .createTable(tableName: tableName, fields: model.fields);
    isTableCreated = true;
  }

  @protected
  Future fetch() async {
    if (!isTableCreated) await createTable();
    // Important: extend this function and call notifyListeners() finally
  }
}
