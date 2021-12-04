import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kioku/component/atom/resizable.dart';
import 'package:kioku/component/molecule/custom_image_picker.dart';
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
  List<PageItem> items = [];

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
    final itemWidthOriginalRatio = itemSize.width / 210;
    final itemHeightOriginalRatio = itemSize.width / 297;
    if (itemWidthOriginalRatio > 1 || itemHeightOriginalRatio > 1) {
      if (itemWidthOriginalRatio > itemHeightOriginalRatio) {
        return Size(1.0, itemHeightOriginalRatio / itemWidthOriginalRatio);
      } else {
        return Size(itemWidthOriginalRatio / itemHeightOriginalRatio, 1.0);
      }
    } else {
      return Size(itemWidthOriginalRatio, itemHeightOriginalRatio);
    }
  }

  Widget basicToolBar() {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
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
                    data: Uint8List.fromList(utf8.encode('')),
                    width: 0.5,
                    height: 0.5,
                    zIndex: items.length);
                items.add(newItem);
                setState(() {
                  items = items;
                });
              },
              icon: const Icon(Icons.post_add_rounded)),
        ],
      ),
    );
  }

  Widget ToolBar() {
    switch (barSelection) {
      case ToolbarType.image:
        return basicToolBar();
      case ToolbarType.text:
        return basicToolBar();
      case ToolbarType.basic:
      default:
        return basicToolBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // TODO: show confirm dialog telling user they will discard all the changes
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
            children: [
              InteractiveViewer(
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
                            child: Center(
                              child: Resizable(
                                initialHeight: 200,
                                initialWidth: 200,
                                containerHeight: constraints.maxHeight,
                                containerWidth: constraints.maxWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
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
                                  child: Image.network(
                                      'https://picsum.photos/250?image=9'),
                                ),
                              ),
                            ),
                          );
                        })),
                  ),
                ),
              ),
              ToolBar(),
              //
              // Testing code
              // for (int i = 0; i < items.length; i++)
              //   PageItemWidget(items[i], (text) {
              //     items[i].data = Uint8List.fromList(utf8.encode(text ?? ''));
              //   }),
              // PageItemWidget(
              //     PageItem(
              //         pageId: widget.id,
              //         type: PageItemType.TEXTBOX,
              //         data: Uint8List.fromList(utf8.encode('testing')),
              //         width: 0.5,
              //         height: 0.5,
              //         zIndex: 2),
              //     (text) {})
            ],
          ),
        ));
  }
}
