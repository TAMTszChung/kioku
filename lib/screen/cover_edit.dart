import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import "package:images_picker/images_picker.dart";
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
  late Book localBookCopy;
  late String title;
  late Color color;
  String? cover;

  @override
  initState() {
    super.initState();
    localBookCopy = context.read<BookProvider>().get(widget.id);
    title = localBookCopy.title;
    color = localBookCopy.color;
    cover = localBookCopy.cover;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Edit Cover'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Save"))
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Please enter a title',
                  helperText: 'maximum length: 30',
                  contentPadding: EdgeInsets.fromLTRB(12, 5, 12, 5)),
              onChanged: (text) {
                setState(() {
                  title = text;
                });
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: Text(
                'Color of cover',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                backgroundColor: color,
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: HueRingPicker(
                          pickerColor: color,
                          onColorChanged: (Color newColor) {
                            setState(() {
                              color = newColor;
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
                print('called');

                List<Media>? res = await ImagesPicker.pick(
                  count: 1,
                  pickType: PickType.image,
                );

                print(res.toString());
                if (res == null) {
                  return;
                }
                final imageBytes = io.File(res[0].path).readAsBytesSync();
                String base64Image = base64Encode(imageBytes);
                print(base64Image);

                setState(() {
                  cover = base64Image;
                });
              },
              child: const Text('Choose an image'),
            ),
          ],
        ));
  }
}
