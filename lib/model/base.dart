import 'package:kioku/service/database.dart';

abstract class BaseModel {
  late final List<DBField> fields;
  BaseModel({required this.fields});
}
