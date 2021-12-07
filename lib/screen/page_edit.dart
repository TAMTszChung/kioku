import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kioku/component/atom/transformable.dart';
import 'package:kioku/component/molecule/custom_image_picker.dart';
import 'package:kioku/component/molecule/page_item.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';

enum ToolbarType { basic, text, image }

class PageEditPage extends StatefulWidget {
  final int id;

  const PageEditPage(this.id, {Key? key}) : super(key: key);

  @override
  State<PageEditPage> createState() => _PageEditPageState();
}

class _PageEditPageState extends State<PageEditPage> {
  bool saving = false;
  ToolbarType barSelection = ToolbarType.basic;

  late BookPage page;
  late List<PageItem> items;

  PageItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    page = context.read<BookPageProvider>().get(widget.id).copy();
    items = context
        .read<PageItemProvider>()
        .getAllByPageId(widget.id)
        .map((item) => item.copy())
        .toList();
  }

  Size dimensionToAllowedPercentage(Size itemSize) {
    double itemWidthOriginalRatio = itemSize.width / 210;
    double itemHeightOriginalRatio = itemSize.height / 297;
    if (itemWidthOriginalRatio > 1 || itemHeightOriginalRatio > 1) {
      if (itemWidthOriginalRatio > itemHeightOriginalRatio) {
        return Size(
            0.8, (itemHeightOriginalRatio / itemWidthOriginalRatio) * 0.8);
      } else {
        return Size(
            (itemWidthOriginalRatio / itemHeightOriginalRatio) * 0.8, 0.8);
      }
    } else {
      return Size(itemWidthOriginalRatio, itemHeightOriginalRatio);
    }
  }

  Widget basicToolBar(BuildContext context) {
    return Wrap(
      children: [
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: HueRingPicker(
                        pickerColor: page.color,
                        onColorChanged: (Color newColor) {
                          page.color = newColor;
                          setState(() {
                            page = page;
                          });
                        },
                        enableAlpha: false,
                        displayThumbColor: true,
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.format_color_fill)),
        IconButton(
            onPressed: () async {
              final File? res = await CustomImagePicker.pickMedia(
                  isGallery: true, fixRatio: false);
              if (res == null) {
                return;
              }
              final imageBytes = await File(res.path).readAsBytes();
              final imageFile = await decodeImageFromList(imageBytes);

              final ratioDimension = dimensionToAllowedPercentage(Size(
                  imageFile.width.toDouble(), imageFile.height.toDouble()));

              final newItem = PageItem(
                  pageId: widget.id,
                  type: PageItemType.IMAGE,
                  data: imageBytes,
                  coordinates: const Point(0.1, 0.1),
                  width: ratioDimension.width,
                  height: ratioDimension.height,
                  zIndex: items.length);
              items.add(newItem);
              setState(() {
                items = items;
              });
            },
            icon: const Icon(Icons.add_photo_alternate)),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: IconButton(
              onPressed: () async {
                final File? res = await CustomImagePicker.pickMedia(
                    isGallery: false, fixRatio: false);
                if (res == null) {
                  return;
                }
                final imageBytes = await File(res.path).readAsBytes();
                final imageFile = await decodeImageFromList(imageBytes);

                final ratioDimension = dimensionToAllowedPercentage(Size(
                    imageFile.width.toDouble(), imageFile.height.toDouble()));

                final newItem = PageItem(
                    pageId: widget.id,
                    type: PageItemType.IMAGE,
                    data: imageBytes,
                    coordinates: const Point<double>(0.1, 0.1),
                    width: ratioDimension.width,
                    height: ratioDimension.height,
                    zIndex: items.length);
                items.add(newItem);
                setState(() {
                  items = items;
                });
              },
              icon: const Icon(Icons.add_a_photo)),
        ),
        IconButton(
            onPressed: () {
              final newItem = PageItem(
                  pageId: widget.id,
                  type: PageItemType.TEXTBOX,
                  data: Uint8List.fromList(utf8.encode('Type some text')),
                  coordinates: const Point(0.1, 0.1),
                  width: 0.5,
                  height: 0.2,
                  zIndex: items.length);
              items.add(newItem);
              setState(() {
                items = items;
              });
            },
            icon: const Icon(Icons.post_add_rounded)),
      ],
    );
  }

  Widget toolbar(BuildContext context) {
    if (_selectedItem == null) {
      return Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: basicToolBar(context),
      );
    }

    switch (barSelection) {
      case ToolbarType.image:
        return Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: basicToolBar(context),
        );
      case ToolbarType.text:
        return Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: basicToolBar(context),
        );
      case ToolbarType.basic:
      default:
        return Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: basicToolBar(context),
        );
    }
  }

  Widget inputBar() {
    if (_selectedItem == null) {
      return const SizedBox(
        width: 1,
        height: 1,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: TextFormField(
          initialValue: utf8.decode(_selectedItem!.data),
          decoration: InputDecoration(
            hintText: 'Type here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          ),
          autofocus: true,
          maxLines: 1,
          onChanged: (text) {
            _selectedItem!.data = Uint8List.fromList(utf8.encode(text));
            setState(() {
              items = items;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final res = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Leave Edit Page'),
                  content: const Text(
                      'Leaving this page will discard all the changes.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                );
              });

          if (res != null) {
            return true;
          }
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Page'),
            actions: <Widget>[
              saving
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: () async {
                        setState(() {
                          saving = true;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'))
            ],
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              InteractiveViewer(
                onInteractionStart: (details) {
                  setState(() {
                    _selectedItem = null;
                  });
                },
                minScale: 0.6,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(150),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: AspectRatio(
                        aspectRatio: 210 / 297,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            decoration: BoxDecoration(
                              color: page.color,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: items.map((item) {
                                final double left =
                                    item.coordinates.x * constraints.maxWidth;
                                final double top =
                                    item.coordinates.y * constraints.maxHeight;
                                final double height =
                                    item.height * constraints.maxHeight;
                                final double width =
                                    item.width * constraints.maxWidth;

                                final Widget itemWidget =
                                    PageItemWidget(item, (text) {
                                  item.data = Uint8List.fromList(
                                      utf8.encode(text ?? ''));
                                });

                                if (item == _selectedItem) {
                                  return Transformable(
                                    child: itemWidget,
                                    size: Size(width, height),
                                    position: Offset(left, top),
                                    rotation: item.rotation,
                                    isText: item.type == PageItemType.TEXTBOX,
                                    onTransform: (size, position, rotation) {
                                      item.width =
                                          size.width / constraints.maxWidth;
                                      item.height =
                                          size.height / constraints.maxHeight;
                                      final newX =
                                          position.dx / constraints.maxWidth;
                                      final newY =
                                          position.dy / constraints.maxHeight;
                                      item.coordinates = Point(newX, newY);
                                      item.rotation = rotation;
                                      setState(() {
                                        items = items;
                                      });
                                    },
                                  );
                                } else {
                                  return Positioned(
                                      top: top,
                                      left: left,
                                      child: Transform.rotate(
                                          angle: item.rotation,
                                          child: SizedBox(
                                            height: height,
                                            width: width,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTapDown: (details) {
                                                setState(() {
                                                  _selectedItem = item;
                                                });
                                              },
                                              child: item.type ==
                                                      PageItemType.IMAGE
                                                  ? FittedBox(
                                                      child: itemWidget,
                                                      fit: BoxFit.fill)
                                                  : itemWidget,
                                            ),
                                          )));
                                }
                              }).toList(),
                            ),
                          );
                        })),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: toolbar(context),
              ),
              if (_selectedItem != null &&
                  _selectedItem!.type == PageItemType.TEXTBOX)
                inputBar(),
            ],
          ),
        ));
  }
}
