/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

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
    await DBHelper.instance.createTable(tableName: tableName, cols: model.cols);
    isTableCreated = true;
  }

  @protected
  Future<bool> fetchAll() async {
    if (!isTableCreated) await createTable();
    return true;
    // Important: extend this function and call notifyListeners() finally
  }
}
