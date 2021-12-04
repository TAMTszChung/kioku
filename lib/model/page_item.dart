import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

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
  static const zIndex = 'z_index';
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
          DBCol(name: attributes, type: DBType.text(notNull: true)),
          DBCol(name: categories, type: DBType.text()),
          DBCol(name: coordinateX, type: DBType.real(notNull: true)),
          DBCol(name: coordinateY, type: DBType.real(notNull: true)),
          DBCol(name: width, type: DBType.real(notNull: true)),
          DBCol(name: height, type: DBType.real(notNull: true)),
          DBCol(name: rotation, type: DBType.real(notNull: true)),
          DBCol(name: zIndex, type: DBType.int(notNull: true)),
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
  Uint8List data; // data in bytes
  Map<String, String> attributes; // attributes of data
  List<String>? categories; // categories
  Point<double> coordinates; // coordinates (x, y are in percent)
  double width; // width (in percent)
  double height; // height (in percent)
  double rotation; // rotation (in radian)
  int zIndex; // z-index (larger = closer to surface)
  DateTime? datetime; // datetime
  final DateTime createTime; // create time from database
  DateTime lastModifiedTime; // last modified time from database

  PageItem._internal(
      {this.id,
      required this.pageId,
      this.name,
      required this.type,
      required this.data,
      required this.attributes,
      this.categories,
      required this.coordinates,
      required this.width,
      required this.height,
      required this.rotation,
      required this.zIndex,
      this.datetime,
      required this.createTime,
      required this.lastModifiedTime});

  factory PageItem(
      {required int pageId,
      String? name,
      required PageItemType type,
      required Uint8List data,
      Point<double> coordinates = const Point<double>(0.0, 0.0),
      required double width,
      required double height,
      double rotation = 0.0,
      required int zIndex,
      DateTime? datetime}) {
    final Map<String, String> attributes = {};
    attributes['underline'] = 'false';
    attributes['italic'] = 'false';
    attributes['bold'] = 'false';
    attributes['fontFamily'] = 'Merriweather';
    attributes['fontSize'] = '20';
    attributes['color'] = 'ff000000';
    attributes['backgroundColor'] = '00000000';
    final timestamp = DateTime.now();
    return PageItem._internal(
        pageId: pageId,
        name: name,
        type: type,
        data: data,
        attributes: attributes,
        coordinates: coordinates,
        width: width,
        height: height,
        rotation: rotation,
        zIndex: zIndex,
        datetime: datetime,
        createTime: timestamp,
        lastModifiedTime: timestamp);
  }

  factory PageItem.fromJson(Map<String, Object?> json) {
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
        data: json[PageItemModel.data] as Uint8List,
        attributes: jsonDecode(json[PageItemModel.attributes] as String),
        categories: categories,
        coordinates: Point<double>(json[PageItemModel.coordinateX] as double,
            json[PageItemModel.coordinateY] as double),
        width: json[PageItemModel.width] as double,
        height: json[PageItemModel.height] as double,
        rotation: json[PageItemModel.rotation] as double,
        zIndex: json[PageItemModel.zIndex] as int,
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
    Uint8List? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    int? zIndex,
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
        attributes: attributes ?? Map.from(original.attributes),
        categories: categories ??
            (original.categories != null
                ? List.from(original.categories!)
                : null),
        coordinates: coordinates ?? original.coordinates,
        width: width ?? original.width,
        height: height ?? original.height,
        rotation: rotation ?? original.rotation,
        zIndex: zIndex ?? original.zIndex,
        createTime: createTime ?? original.createTime,
        lastModifiedTime: lastModifiedTime ?? original.lastModifiedTime);
  }

  PageItem copy({
    int? pageId,
    String? name,
    PageItemType? type,
    Uint8List? data,
    Map<String, String>? attributes,
    List<String>? categories,
    Point<double>? coordinates,
    double? width,
    double? height,
    double? rotation,
    int? zIndex,
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
        zIndex: zIndex,
        lastModifiedTime: lastModifiedTime,
        original: this);
  }

  Map<String, Object?> toJson() => {
        PageItemModel.id: id,
        PageItemModel.pageId: pageId,
        PageItemModel.name: name,
        PageItemModel.type: type,
        PageItemModel.data: data,
        PageItemModel.attributes: jsonEncode(attributes),
        PageItemModel.categories: categories?.join(','),
        PageItemModel.coordinateX: coordinates.x,
        PageItemModel.coordinateY: coordinates.y,
        PageItemModel.width: width,
        PageItemModel.height: height,
        PageItemModel.rotation: rotation,
        PageItemModel.zIndex: zIndex,
        PageItemModel.createTime: createTime.millisecondsSinceEpoch,
        PageItemModel.lastModifiedTime: lastModifiedTime.millisecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) =>
      other is PageItem && hashCode == other.hashCode;

  @override
  int get hashCode => const MapEquality().hash(toJson());
}
