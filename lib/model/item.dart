import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:extension/extension.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class ItemModel extends BaseModel {
  static const id = 'id';
  static const pageId = 'page_id';
  static const name = 'name';
  static const type = 'type';
  static const data = 'data';
  static const attributes = 'attributes';
  static const categories = 'categories';
  static const coordinateX = 'x_percent';
  static const coordinateY = 'y_percent';
  static const width = 'width_percent';
  static const height = 'height_percent';
  static const rotation = 'rotation_rad';
  static const datetime = 'datetime';
  static const createTime = 'createTime';
  static const lastModifiedTime = 'lastModifiedTime';

  ItemModel({required String pageTableName, required DBCol pageTableIdCol})
      : super(
            cols: DBCols([
          DBCol(name: id, type: DBType.rowId()),
          DBCol(name: pageId, type: DBType.fromForeign(pageTableIdCol.type)),
          DBCol(name: name, type: DBType.text()),
          DBCol(name: type, type: DBType.text(notNull: true)),
          DBCol(name: data, type: DBType.blob(notNull: true)),
          DBCol(name: attributes, type: DBType.text()),
          DBCol(name: categories, type: DBType.text()),
          DBCol(name: coordinateX, type: DBType.real(notNull: true)),
          DBCol(name: coordinateY, type: DBType.real(notNull: true)),
          DBCol(name: width, type: DBType.real(notNull: true)),
          DBCol(name: height, type: DBType.real(notNull: true)),
          DBCol(name: rotation, type: DBType.real(notNull: true)),
          DBCol(name: datetime, type: DBType.int()),
          DBCol(name: createTime, type: DBType.int(notNull: true)),
          DBCol(name: lastModifiedTime, type: DBType.int(notNull: true)),
        ], foreignKeys: [
          DBForeignKey(
              colNames: [pageId],
              foreignTableName: pageTableName,
              foreignTableColNames: [pageTableIdCol.name]),
        ]));
}

class ItemType extends Enum<String> {
  const ItemType(String value) : super(value);

  // ignore: constant_identifier_names
  static const ItemType TEXTBOX = ItemType('textbox');
  // ignore: constant_identifier_names
  static const ItemType IMAGE = ItemType('image');
}

class Item {
  int? id; // id from database
  int pageId; // id of page owning this item
  String? name; // name
  ItemType type; // type
  String data; // data
  Map<String, String>? attributes; // attributes of data
  List<String>? categories; // categories
  Point<double> coordinates; // coordinates (x, y are in percent)
  double width; // width (in percent)
  double height; // height (in percent)
  double rotation; // rotation (in radian)
  DateTime? datetime; // datetime
  final DateTime createTime; // create time from database
  DateTime lastModifiedTime; // last modified time from database

  Item._internal(
      {this.id,
      required this.pageId,
      this.name,
      required this.type,
      required this.data,
      this.attributes,
      this.categories,
      required this.coordinates,
      required this.width,
      required this.height,
      required this.rotation,
      this.datetime,
      required this.createTime,
      required this.lastModifiedTime});

  factory Item(
      {required int pageId,
      String? name,
      required ItemType type,
      String data = '',
      Point<double> coordinates = const Point<double>(0.0, 0.0),
      required double width,
      required double height,
      double rotation = 0.0,
      DateTime? datetime}) {
    final timestamp = DateTime.now();
    return Item._internal(
        pageId: pageId,
        name: name,
        type: type,
        data: data,
        coordinates: coordinates,
        width: width,
        height: height,
        rotation: rotation,
        datetime: datetime,
        createTime: timestamp,
        lastModifiedTime: timestamp);
  }

  factory Item.fromJson(Map<String, Object?> json) {
    Map<String, String>? attributes;
    var attributesStr = json[ItemModel.attributes] as String?;
    if (attributesStr != null) {
      attributes = jsonDecode(attributesStr, reviver: (key, value) {
        return value is String ? value : value.toString();
      });
    }
    List<String>? categories;
    var categoriesStr = json[ItemModel.categories] as String?;
    if (categoriesStr != null) {
      categories = categoriesStr.split(',');
    }
    return Item._internal(
        id: json[ItemModel.id] as int,
        pageId: json[ItemModel.pageId] as int,
        name: json[ItemModel.name] as String?,
        type: json[ItemModel.type] as ItemType,
        data: json[ItemModel.data] as String,
        attributes: attributes,
        categories: categories,
        coordinates: Point<double>(json[ItemModel.coordinateX] as double,
            json[ItemModel.coordinateY] as double),
        width: json[ItemModel.width] as double,
        height: json[ItemModel.height] as double,
        rotation: json[ItemModel.rotation] as double,
        datetime: DateTime.fromMillisecondsSinceEpoch(
            json[ItemModel.datetime] as int),
        createTime: DateTime.fromMillisecondsSinceEpoch(
            json[ItemModel.createTime] as int),
        lastModifiedTime: DateTime.fromMillisecondsSinceEpoch(
            json[ItemModel.lastModifiedTime] as int));
  }

  factory Item._copy({
    int? id,
    int? pageId,
    String? name,
    ItemType? type,
    String? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required Item original,
  }) {
    return Item._internal(
        id: id ?? original.id,
        pageId: pageId ?? original.pageId,
        name: name ?? original.name,
        type: type ?? original.type,
        data: data ?? original.data,
        attributes: attributes ?? original.attributes,
        categories: categories ?? original.categories,
        coordinates: coordinates ?? original.coordinates,
        width: width ?? original.width,
        height: height ?? original.height,
        rotation: rotation ?? original.rotation,
        createTime: createTime ?? original.createTime,
        lastModifiedTime: lastModifiedTime ?? original.lastModifiedTime);
  }

  Item copy({
    int? pageId,
    String? name,
    ItemType? type,
    String? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    DateTime? lastModifiedTime,
  }) {
    return Item._copy(
        pageId: pageId,
        name: name,
        type: type,
        data: data,
        attributes: attributes,
        categories: categories,
        coordinates: coordinates,
        width: width,
        height: height,
        rotation: rotation,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        ItemModel.id: id,
        ItemModel.pageId: pageId,
        ItemModel.name: name,
        ItemModel.type: type,
        ItemModel.data: data,
        ItemModel.attributes:
            attributes != null ? jsonEncode(attributes) : null,
        ItemModel.categories: categories?.join(','),
        ItemModel.coordinateX: coordinates.x,
        ItemModel.coordinateY: coordinates.y,
        ItemModel.width: width,
        ItemModel.height: height,
        ItemModel.rotation: rotation,
        ItemModel.createTime: createTime.millisecondsSinceEpoch,
        ItemModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) => other is Item && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
