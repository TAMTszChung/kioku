/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kioku/component/atom/input_dialog.dart';
import 'package:kioku/component/atom/transformable.dart';
import 'package:kioku/component/molecule/custom_image_picker.dart';
import 'package:kioku/component/molecule/page_item.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book.dart';
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
  final GlobalKey _globalKey = GlobalKey();

  bool saving = false;

  //current page
  late BookPage page;
  //list of items in page
  late List<PageItem> items;
  //currently selected item in the list
  PageItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    page = context.read<BookPageProvider>().get(widget.id).copy();
  }

  //-------------------------- Utility functions --------------------------
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

  Future<Uint8List?> _capturePng() async {
    try {
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 4);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      return null;
    }
  }
  //-------------------------- Utility functions End ----------------------

  //-------------------------- ToolBar buttons --------------------------
  Widget pageFillColorButton() {
    return IconButton(
        onPressed: !saving
            ? () {
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
              }
            : null,
        icon: const Icon(Icons.format_color_fill));
  }

  Widget chooseImageButton() {
    return IconButton(
        onPressed: !saving
            ? () async {
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
              }
            : null,
        icon: const Icon(Icons.add_photo_alternate));
  }

  Widget takePhotoButton() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: IconButton(
          onPressed: !saving
              ? () async {
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
                }
              : null,
          icon: const Icon(Icons.add_a_photo)),
    );
  }

  Widget addTextBoxButton() {
    return IconButton(
        onPressed: !saving
            ? () async {
                final result = await showTextInputDialog(
                  context,
                  title: 'Add Text',
                  hintText: 'Type some text',
                  okText: 'OK',
                  cancelText: 'Cancel',
                  validator: (text) {
                    return null;
                  },
                );
                if (result == null) {
                  return;
                }

                final newItem = PageItem(
                    pageId: widget.id,
                    type: PageItemType.TEXTBOX,
                    data: Uint8List.fromList(utf8
                        .encode(result.isNotEmpty ? result : 'Type some text')),
                    coordinates: const Point(0.1, 0.1),
                    width: 0.5,
                    height: 0.2,
                    zIndex: items.length);
                items.add(newItem);
                setState(() {
                  items = items;
                });
              }
            : null,
        icon: const Icon(Icons.post_add_rounded));
  }

  Widget toBackButton() {
    return IconButton(
        onPressed: (items.length == 1 || items.indexOf(_selectedItem!) == 0)
            ? null
            : () {
                final itemIndex = items.indexOf(_selectedItem!);
                if (itemIndex == 0) return;

                PageItem temp = items[itemIndex - 1];
                items[itemIndex - 1] = _selectedItem!;
                items[itemIndex] = temp;
                setState(() {
                  items = items;
                });
              },
        icon: const Icon(Icons.flip_to_back));
  }

  Widget toFrontButton() {
    return IconButton(
        onPressed: (items.length == 1 ||
                items.indexOf(_selectedItem!) == items.length - 1)
            ? null
            : () {
                final itemIndex = items.indexOf(_selectedItem!);
                if (itemIndex == items.length - 1) return;

                PageItem temp = items[itemIndex + 1];
                items[itemIndex + 1] = _selectedItem!;
                items[itemIndex] = temp;
                setState(() {
                  items = items;
                });
              },
        icon: const Icon(Icons.flip_to_front));
  }

  Widget deleteButton() {
    return IconButton(
        onPressed: () {
          items.removeWhere((item) => item == _selectedItem);
          setState(() {
            _selectedItem = null;
            items = items;
          });
        },
        icon: const Icon(Icons.delete_forever));
  }

  Widget editTextButton() {
    return IconButton(
        onPressed: _selectedItem != null
            ? () async {
                final result = await showTextInputDialog(
                  context,
                  title: 'Edit Text',
                  hintText: 'Type some text',
                  okText: 'OK',
                  cancelText: 'Cancel',
                  initValue: utf8.decode(_selectedItem!.data),
                  validator: (text) {
                    return null;
                  },
                );

                if (result == null) return;

                _selectedItem!.data = Uint8List.fromList(utf8.encode(result));
                setState(() {
                  items = items;
                });
              }
            : null,
        icon: const Icon(Icons.edit));
  }

  Widget underlineButton() {
    return IconButton(
        onPressed: _selectedItem != null
            ? () {
                _selectedItem!.attributes['underline'] =
                    _selectedItem!.attributes['underline'] == 'false'
                        ? 'true'
                        : 'false';
                setState(() {
                  items = items;
                });
              }
            : null,
        icon: const Icon(Icons.format_underline));
  }

  Widget italicButton() {
    return IconButton(
        onPressed: _selectedItem != null
            ? () {
                _selectedItem!.attributes['italic'] =
                    _selectedItem!.attributes['italic'] == 'false'
                        ? 'true'
                        : 'false';
                setState(() {
                  items = items;
                });
              }
            : null,
        icon: const Icon(Icons.format_italic));
  }

  Widget boldButton() {
    return IconButton(
        onPressed: _selectedItem != null
            ? () {
                _selectedItem!.attributes['bold'] =
                    _selectedItem!.attributes['bold'] == 'false'
                        ? 'true'
                        : 'false';
                setState(() {
                  items = items;
                });
              }
            : null,
        icon: const Icon(Icons.format_bold));
  }

  Widget fontButton() {
    List<String> fonts = [
      'Abril Fatface',
      'Arvo',
      'Dancing Script',
      'Indie Flower',
      'Lato',
      'Lobster',
      'Merriweather',
      'Oswald',
      'Pacifico',
      'Playfair Display',
      'Raleway',
      'Saira Condensed',
      'Shadows Into Light',
    ];
    return DropdownButton<String>(
      value: _selectedItem!.attributes['fontFamily'],
      //icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        if (newValue == null) return;
        _selectedItem!.attributes['fontFamily'] = newValue;
        setState(() {
          items = items;
        });
      },
      items: fonts.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.getFont(value),
          ),
        );
      }).toList(),
    );
  }

  Widget fontSizeButton() {
    double originalFontSize = 20;
    try {
      originalFontSize = double.parse(_selectedItem!.attributes['fontSize']!);
    } catch (e) {
      originalFontSize = 20;
    }

    List<double> sizes = [
      8.0,
      9.0,
      10.0,
      10.5,
      11.0,
      12.0,
      14.0,
      16.0,
      18.0,
      22.0,
      24.0,
      26.0,
      28.0,
      32.0,
      36.0,
      40.0,
      44.0,
      48.0,
      72.0
    ];
    return DropdownButton<double>(
      value: originalFontSize,
      //icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (double? newValue) {
        if (newValue == null) return;
        _selectedItem!.attributes['fontSize'] = newValue.toString();
        setState(() {
          items = items;
        });
      },
      items: sizes.map<DropdownMenuItem<double>>((double value) {
        return DropdownMenuItem<double>(
          value: value,
          child: Text(
            value.toString(),
          ),
        );
      }).toList(),
    );
  }

  Widget textColorButton() {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: HueRingPicker(
                    pickerColor: page.color,
                    onColorChanged: (Color newColor) {
                      _selectedItem!.attributes['color'] =
                          newColor.value.toRadixString(16);
                      setState(() {
                        items = items;
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
        icon: const Icon(Icons.format_color_text));
  }

  Widget textHighlightColorButton() {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: HueRingPicker(
                    pickerColor: page.color,
                    onColorChanged: (Color newColor) {
                      _selectedItem!.attributes['highlightColor'] =
                          newColor.value.toRadixString(16);
                      setState(() {
                        items = items;
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
        icon: const Icon(Icons.border_color));
  }

  Widget textBoxColorButton() {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: HueRingPicker(
                    pickerColor: page.color,
                    onColorChanged: (Color newColor) {
                      _selectedItem!.attributes['backgroundColor'] =
                          newColor.value.toRadixString(16);
                      setState(() {
                        items = items;
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
        icon: const Icon(Icons.format_color_fill));
  }
  // -------------------------- ToolBar buttons End ----------------------

  //-------------------------- Different ToolBars --------------------------
  Widget basicToolBar() {
    return Wrap(
      children: [
        pageFillColorButton(),
        chooseImageButton(),
        takePhotoButton(),
        addTextBoxButton(),
      ],
    );
  }

  Widget imageToolBar() {
    return Wrap(
      children: [
        toBackButton(),
        toFrontButton(),
        deleteButton(),
      ],
    );
  }

  Widget textToolBar() {
    return Wrap(
      spacing: 3,
      children: [
        editTextButton(),
        underlineButton(),
        italicButton(),
        boldButton(),
        fontButton(),
        fontSizeButton(),
        textColorButton(),
        textHighlightColorButton(),
        textBoxColorButton(),
        toBackButton(),
        toFrontButton(),
        deleteButton(),
      ],
    );
  }
  //-------------------------- Different ToolBars End ----------------------

  //-------------------------- ToolBar Wrapper --------------------------
  Widget toolbar(BuildContext context) {
    if (_selectedItem == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
        child: basicToolBar(),
      );
    }

    if (_selectedItem!.type == PageItemType.IMAGE) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
        child: imageToolBar(),
      );
    }

    if (_selectedItem!.type == PageItemType.TEXTBOX) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
        child: textToolBar(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
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
      child: basicToolBar(),
    );
  }
  //-------------------------- ToolBar Wrapper End ----------------------

  @override
  Widget build(BuildContext context) {
    items = context
        .select<PageItemProvider, List<PageItem>>(
            (p) => p.getAllByPageId(widget.id))
        .map((item) => item.copy())
        .toList();

    return WillPopScope(
        //-------------------------- Perform Exit Check -----------------------
        onWillPop: () async {
          if (saving) {
            return false;
          }

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
        //-------------------------- Current Screen --------------------------
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Page'),
            actions: <Widget>[
              saving
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator())))
                  : IconButton(
                      onPressed: !saving
                          ? () async {
                              setState(() {
                                _selectedItem = null;
                                saving = true;
                              });

                              final List<PageItem> copiedItems =
                                  items.map((item) => item.copy()).toList();

                              for (int i = 0; i < copiedItems.length; i++) {
                                copiedItems[i].zIndex = i;
                              }

                              await context
                                  .read<PageItemProvider>()
                                  .setAll(widget.id, copiedItems);

                              await Future.delayed(
                                  const Duration(milliseconds: 300), () async {
                                //update page thumbnail
                                Uint8List? pageSnapshot;
                                await _capturePng()
                                    .then((value) => pageSnapshot = value);
                                final BookPage newPage =
                                    page.copy(thumbnail: pageSnapshot);

                                await context
                                    .read<BookPageProvider>()
                                    .update(newPage);

                                //update book time
                                final Book book = context
                                    .read<BookProvider>()
                                    .get(page.bookId);
                                await context.read<BookProvider>().update(book);

                                //pop screen
                                Navigator.pop(context);
                              });
                            }
                          : null,
                      icon: const Icon(Icons.save))
            ],
          ),
          //-------------------- Interactive Viewer -------------------
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
                  //-------------------- Page Container -------------------
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
                              //-------------- Widget Stack --------------
                              child: RepaintBoundary(
                                key: _globalKey,
                                child: Stack(
                                  children: items.map((item) {
                                    final double left = item.coordinates.x *
                                        constraints.maxWidth;
                                    final double top = item.coordinates.y *
                                        constraints.maxHeight;
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
                                        isText:
                                            item.type == PageItemType.TEXTBOX,
                                        onTransform:
                                            (size, position, rotation) {
                                          item.width =
                                              size.width / constraints.maxWidth;
                                          item.height = size.height /
                                              constraints.maxHeight;
                                          final newX = position.dx /
                                              constraints.maxWidth;
                                          final newY = position.dy /
                                              constraints.maxHeight;
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
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTapDown: (details) {
                                                    if (saving) return;
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
                              ));
                        })),
                  ),
                ),
              ),
              /*
              ---------------- ToolBar on top of viewer ----------------
              */
              Positioned(
                top: 0,
                child: toolbar(context),
              ),
            ],
          ),
        ));
  }
}
