import 'package:kioku/service/database.dart';

abstract class BaseModel {
  final DBCols cols;
  BaseModel({required this.cols});
}
