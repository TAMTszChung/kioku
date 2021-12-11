/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kioku/component/molecule/book.dart';
import 'package:kioku/component/molecule/custom_image_picker.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/provider/book.dart';
import 'package:provider/provider.dart';

class CoverEditPage extends StatefulWidget {
  final int id;

  const CoverEditPage(this.id, {Key? key}) : super(key: key);

  @override
  State<CoverEditPage> createState() => _CoverEditPageState();
}

class _CoverEditPageState extends State<CoverEditPage> {
  late Book book;
  bool saving = false;
  String errorMsg = '';

  @override
  initState() {
    super.initState();
    book = context.read<BookProvider>().get(widget.id).copy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Cover'),
          actions: <Widget>[
            saving
                ? const CircularProgressIndicator()
                : IconButton(
                    onPressed: errorMsg.isEmpty
                        ? () async {
                            await context.read<BookProvider>().update(book);
                            Navigator.pop(context);
                          }
                        : null,
                    icon: const Icon(Icons.save)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            TextFormField(
              maxLength: Book.titleLengthLimit,
              initialValue: book.title,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Please enter a title',
                  contentPadding: EdgeInsets.fromLTRB(12, 5, 12, 5)),
              onChanged: (text) {
                if (text.isEmpty) {
                  errorMsg = '*  Title cannot be empty';
                } else if (RegExp('[^\x00-\x7F]+').hasMatch(text)) {
                  errorMsg = 'Title cannot contain unicode characters';
                } else {
                  errorMsg = '';
                }

                book.title = text;
                setState(() {
                  book = book;
                  errorMsg = errorMsg;
                });
              },
            ),
            Visibility(
              child: Text(
                errorMsg,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              visible: errorMsg.isNotEmpty,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text(
                'Color of cover',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                backgroundColor: book.color,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: book.cover != null
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: HueRingPicker(
                                pickerColor: book.color,
                                onColorChanged: (Color newColor) {
                                  book.color = newColor;
                                  setState(() {
                                    book = book;
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
              child: const Text(''),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text(
                'Book cover image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                final File? res = await CustomImagePicker.pickMedia(
                    isGallery: true, fixRatio: true);
                if (res == null) return;
                book.cover = await File(res.path).readAsBytes();
                setState(() {
                  book = book;
                });
              },
              child: const Text('Pick an image'),
            ),
            OutlinedButton(
              onPressed: () async {
                final File? res = await CustomImagePicker.pickMedia(
                    isGallery: false, fixRatio: true);
                if (res == null) return;
                book.cover = await File(res.path).readAsBytes();
                setState(() {
                  book = book;
                });
              },
              child: const Text('Take a photo'),
            ),
            OutlinedButton(
              onPressed: book.cover != null
                  ? () {
                      book.cover = null;
                      setState(() {
                        book = book;
                      });
                    }
                  : null,
              child: const Text('Clear'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text(
                'Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            BookWidget(book),
          ],
        ));
  }
}
