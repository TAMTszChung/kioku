/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:kioku/component/organism/book_cardview.dart';
import 'package:kioku/component/organism/book_listview.dart';
import 'package:kioku/component/organism/book_pageview.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/model/book_page.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

void generateBookPdf(SendPort port) {
  final rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((message) {
    final send = message[0] as SendPort;
    final book = message[1] as Book;
    final pages = message[2] as List<BookPage>;
    final tempDir = message[3] as Directory;
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: const PdfPageFormat(
            21.0 * PdfPageFormat.cm,
            29.7 * PdfPageFormat.cm,
          ),
          buildBackground: (pw.Context context) => pw.Container(
              decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(15),
          )),
        ),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.AspectRatio(
                aspectRatio: 210 / 297,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: book.cover == null
                        ? PdfColor.fromHex(
                            book.color.value.toRadixString(16).substring(2))
                        : null,
                    image: book.cover != null
                        ? pw.DecorationImage(
                            image: pw.MemoryImage(book.cover!),
                            fit: pw.BoxFit.cover,
                          )
                        : null,
                    borderRadius: pw.BorderRadius.circular(15),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor.fromHex('9e9e9e7f'),
                        spreadRadius: 3,
                        blurRadius: 7,
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 15),
                  child: pw.Align(
                      alignment: const pw.Alignment(0, -0.5),
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('ffffffb3'),
                          ),
                          constraints: const pw.BoxConstraints(
                              minHeight: 10, maxHeight: 14 * 3.5),
                          width: double.infinity,
                          child: pw.Center(
                            child: pw.Text(
                              book.title,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColor.fromHex('000000'),
                                fontWeight: pw.FontWeight.normal,
                                decoration: pw.TextDecoration.none,
                              ),
                            ),
                          ))),
                )),
          );
        }));

    for (var page in pages) {
      pdf.addPage(pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: const PdfPageFormat(
              21.0 * PdfPageFormat.cm,
              29.7 * PdfPageFormat.cm,
            ),
            buildBackground: (pw.Context context) => pw.Container(
                decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(15),
            )),
          ),
          build: (pw.Context context) {
            return pw.Center(
                child: pw.AspectRatio(
                    aspectRatio: 210 / 297,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex(
                            page.color.value.toRadixString(16).substring(2)),
                        image: page.thumbnail != null
                            ? pw.DecorationImage(
                                image: pw.MemoryImage(page.thumbnail!),
                                fit: pw.BoxFit.cover,
                              )
                            : null,
                        borderRadius: pw.BorderRadius.circular(15),
                        boxShadow: [
                          pw.BoxShadow(
                            color: PdfColor.fromHex('9e9e9e7f'),
                            spreadRadius: 3,
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    )));
          }));
    }

    pdf.save().then((bytes) {
      final file = File('${tempDir.path}/${book.title}.pdf');
      return file.writeAsBytes(bytes);
    }).then((file) {
      send.send(file);
    });
  });
}

class BookOverview extends StatefulWidget {
  final int id;

  const BookOverview(this.id, {Key? key}) : super(key: key);

  final String title = 'Book Overview';

  @override
  State<BookOverview> createState() => _BookOverviewState();
}

class _BookOverviewState extends State<BookOverview> {
  String _viewMode = 'Book';
  bool addingPage = false;
  String _selectedCategory = 'All';
  bool exporting = false;
  bool saving = false;

  late Book book;
  List<BookPage> pages = [];

  Future<File> getBookPdf() async {
    final response = ReceivePort();
    final tempDir = await getTemporaryDirectory();
    await Isolate.spawn(generateBookPdf, response.sendPort);
    final sendPort = await response.first;
    final answer = ReceivePort();
    sendPort.send([answer.sendPort, book, pages, tempDir]);
    return await answer.first;
  }

  Widget showSubView() {
    switch (_viewMode) {
      case 'List':
        return BookListView(widget.id, _selectedCategory);
      case 'Card':
        return BookCardView(widget.id, _selectedCategory);
      case 'Book':
      default:
        return BookPageView(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final providerBook = provider.get(widget.id).copy();
    final pageProvider = context.watch<BookPageProvider>();
    final providerPages =
        pageProvider.getAllByBookId(widget.id).map((p) => p.copy()).toList();

    setState(() {
      book = providerBook;
      pages = providerPages;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: <Widget>[
          if (_viewMode == 'Book')
            IconButton(
                onPressed: pages.length > 1
                    ? () {
                        Navigator.pushNamed(context, '/page_reorder',
                            arguments: widget.id);
                      }
                    : null,
                icon: const Icon(Icons.swap_calls)),
          if (_viewMode == 'Book')
            IconButton(
                onPressed: addingPage
                    ? null
                    : () async {
                        setState(() {
                          addingPage = true;
                        });
                        await pageProvider.insert(BookPage(bookId: widget.id));
                        await provider.update(book);
                        setState(() {
                          addingPage = false;
                        });
                      },
                icon: const Icon(Icons.add)),
          if (_viewMode != 'Book')
            PopupMenuButton<String>(
              icon: _selectedCategory == 'All'
                  ? const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.black,
                    )
                  : const Icon(
                      Icons.filter_alt,
                      color: Colors.black,
                    ),
              onSelected: (String result) {
                setState(() {
                  _selectedCategory = result;
                });
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'Filter By Category',
                    child: Text('Filter By Category'),
                    enabled: false,
                  ),
                  const PopupMenuDivider(
                    height: 1,
                  ),
                  const PopupMenuItem<String>(
                    value: 'All',
                    child: Text('All'),
                  ),
                  ...PageItem.categoryList
                      .map((category) => PopupMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                ];
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.dashboard_rounded,
              color: Colors.black,
            ),
            onSelected: (String result) {
              setState(() {
                _viewMode = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'View Mode',
                child: Text('View Mode'),
                enabled: false,
              ),
              const PopupMenuDivider(
                height: 1,
              ),
              const PopupMenuItem<String>(
                value: 'Book',
                child: Text('Book'),
              ),
              const PopupMenuItem<String>(
                value: 'Card',
                child: Text('Card'),
              ),
              const PopupMenuItem<String>(
                value: 'List',
                child: Text('List'),
              ),
            ],
          ),
          IconButton(
              onPressed: exporting || saving
                  ? null
                  : () async {
                      setState(() {
                        exporting = true;
                      });
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Text('Exporting'),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      final file = await getBookPdf();
                      Navigator.pop(context);
                      await Share.shareFiles([file.path]);
                      setState(() {
                        exporting = false;
                      });
                    },
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: exporting || saving
                  ? null
                  : () async {
                      setState(() {
                        saving = true;
                      });
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Text('Exporting'),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      final file = await getBookPdf();
                      Navigator.pop(context);
                      final params =
                          SaveFileDialogParams(sourceFilePath: file.path);
                      await FlutterFileDialog.saveFile(params: params);
                      setState(() {
                        saving = false;
                      });
                    },
              icon: const Icon(Icons.save_alt)),
        ],
      ),
      body: showSubView(),
    );
  }
}
