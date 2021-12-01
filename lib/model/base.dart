import 'package:kioku/service/database.dart';

abstract class BaseModel {
  final DBFields fields;
  BaseModel({required this.fields});
}
