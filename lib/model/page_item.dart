import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:extension/extension.dart';
import 'package:kioku/model/base.dart';
import 'package:kioku/service/database.dart';

class PageItemModel extends BaseModel {
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

  PageItemModel({required String pageTableName, required DBCol pageTableIdCol})
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

class PageItemType extends Enum<String> {
  const PageItemType(String value) : super(value);

  // ignore: constant_identifier_names
  static const PageItemType TEXTBOX = PageItemType('textbox');
  // ignore: constant_identifier_names
  static const PageItemType IMAGE = PageItemType('image');
}

class PageItem {
  int? id; // id from database
  int pageId; // id of page owning this item
  String? name; // name
  PageItemType type; // type
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

  PageItem._internal(
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

  factory PageItem(
      {required int pageId,
      String? name,
      required PageItemType type,
      String data = '',
      Point<double> coordinates = const Point<double>(0.0, 0.0),
      required double width,
      required double height,
      double rotation = 0.0,
      DateTime? datetime}) {
    final timestamp = DateTime.now();
    return PageItem._internal(
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

  factory PageItem.fromJson(Map<String, Object?> json) {
    Map<String, String>? attributes;
    final attributesStr = json[PageItemModel.attributes] as String?;
    if (attributesStr != null) {
      attributes = jsonDecode(attributesStr, reviver: (key, value) {
        return value is String ? value : value.toString();
      });
    }
    List<String>? categories;
    final categoriesStr = json[PageItemModel.categories] as String?;
    if (categoriesStr != null) {
      categories = categoriesStr.split(',');
    }
    return PageItem._internal(
        id: json[PageItemModel.id] as int,
        pageId: json[PageItemModel.pageId] as int,
        name: json[PageItemModel.name] as String?,
        type: json[PageItemModel.type] as PageItemType,
        data: json[PageItemModel.data] as String,
        attributes: attributes,
        categories: categories,
        coordinates: Point<double>(json[PageItemModel.coordinateX] as double,
            json[PageItemModel.coordinateY] as double),
        width: json[PageItemModel.width] as double,
        height: json[PageItemModel.height] as double,
        rotation: json[PageItemModel.rotation] as double,
        datetime: DateTime.fromMillisecondsSinceEpoch(
            json[PageItemModel.datetime] as int),
        createTime: DateTime.fromMillisecondsSinceEpoch(
            json[PageItemModel.createTime] as int),
        lastModifiedTime: DateTime.fromMillisecondsSinceEpoch(
            json[PageItemModel.lastModifiedTime] as int));
  }

  factory PageItem._copy({
    int? id,
    int? pageId,
    String? name,
    PageItemType? type,
    String? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    DateTime? createTime,
    DateTime? lastModifiedTime,
    required PageItem original,
  }) {
    return PageItem._internal(
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

  PageItem copy({
    int? pageId,
    String? name,
    PageItemType? type,
    String? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    DateTime? lastModifiedTime,
  }) {
    return PageItem._copy(
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
        PageItemModel.id: id,
        PageItemModel.pageId: pageId,
        PageItemModel.name: name,
        PageItemModel.type: type,
        PageItemModel.data: data,
        PageItemModel.attributes:
            attributes != null ? jsonEncode(attributes) : null,
        PageItemModel.categories: categories?.join(','),
        PageItemModel.coordinateX: coordinates.x,
        PageItemModel.coordinateY: coordinates.y,
        PageItemModel.width: width,
        PageItemModel.height: height,
        PageItemModel.rotation: rotation,
        PageItemModel.createTime: createTime.millisecondsSinceEpoch,
        PageItemModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) =>
      other is PageItem && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
