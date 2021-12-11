/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  final String title = 'Help';

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static ThemeData? theme;

  static final List<_Faq> faqs = [
    const _Faq(
        question: 'What is Kioku?',
        answer: Text(
            'Kioku is a digital memory book creation tool. You can create your own memory books, customize the book cover, and freely edit the book pages using items like text and image. Record all precious moments in your life with Kioku now!')),
    _Faq(
        question: 'How to create a book?',
        answer: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                  text:
                      'After you start Kioku, you are in the Collection Books Screen (or you can tap the '),
              WidgetSpan(
                child: Column(
                  children: const [
                    Icon(
                      Icons.book,
                      size: 12.0,
                      color: Colors.black54,
                    ),
                    Text(
                      'Collection Books',
                      style: TextStyle(fontSize: 8, color: Colors.black54),
                    )
                  ],
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              const TextSpan(
                  text:
                      ' tab at the bottom navigation bar to enter). From there, click the '),
              const WidgetSpan(
                  child: Icon(Icons.add, size: 20.0),
                  alignment: PlaceholderAlignment.middle),
              const TextSpan(
                  text:
                      ' button on the top bar to create a new book. You will be prompted for its title, press "OK" after inputting.'),
            ],
          ),
        )),
    _Faq(
        question: 'How to delete a book?',
        answer: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                  text:
                      'After you start Kioku, you are in the Collection Books Screen (or you can tap the '),
              WidgetSpan(
                child: Column(
                  children: const [
                    Icon(
                      Icons.book,
                      size: 12,
                      color: Colors.black54,
                    ),
                    Text(
                      'Collection Books',
                      style: TextStyle(fontSize: 8, color: Colors.black54),
                    )
                  ],
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              const TextSpan(
                  text:
                      ' tab at the bottom navigation bar to enter). From there, long-press the book you want to delete and drag it onto the '),
              WidgetSpan(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    constraints: const BoxConstraints(
                        minHeight: 12,
                        maxHeight: 16,
                        minWidth: 96,
                        maxWidth: 128),
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                    ),
                  ),
                  alignment: PlaceholderAlignment.middle),
              const TextSpan(
                  text:
                      ' bar appeared at the bottom. When the bar turns red, release the book to delete.'),
            ],
          ),
        )),
    const _Faq(
        question: 'How to share a book as a PDF file?',
        answer: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text:
                      'From the Collection Books Screen, tap on the book you want to share. You will then enter the Book Overview Screen. From there, click the '),
              WidgetSpan(
                child: Icon(
                  Icons.share,
                  size: 20,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                  text:
                      ' button at the top bar. Wait patiently for the export to finish and you will be prompted for the method of sharing corresponding to your platform.'),
            ],
          ),
        )),
    const _Faq(
        question: 'How to export a book as a PDF file?',
        answer: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text:
                      'From the Collection Books Screen, tap on the book you want to share. You will then enter the Book Overview Screen. From there, click the '),
              WidgetSpan(
                child: Icon(
                  Icons.save_alt,
                  size: 20,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                  text:
                      ' button at the top bar. Wait patiently for the export to finish and you will be asked for the location to save the file.'),
            ],
          ),
        )),
    const _Faq(
        question: 'How to customize the book cover / change the book title?',
        answer: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    'From the Collection Books Screen, tap on the book you want to edit. You will then enter the Book Overview Screen. Click the book cover page (the topmost page) to enter the Page Slideshow Screen, finally click the ',
              ),
              WidgetSpan(
                child: Icon(
                  Icons.edit,
                  size: 20,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                text:
                    ' button at the top bar to enter the editing form. After you complete editing, remember to press the ',
              ),
              WidgetSpan(
                child: Icon(
                  Icons.save,
                  size: 20,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                text: ' button at the top bar to save your changes.',
              ),
            ],
          ),
        )),
    const _Faq(
      question: 'How to add new pages to a book?',
      answer: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  'From the Collection Books Screen, tap on the book you want to edit. You will then enter the Book Overview Screen. Click the ',
            ),
            WidgetSpan(
              child: Icon(
                Icons.add,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text:
                  ' button at the top bar to add a new page at the end of the book.',
            ),
          ],
        ),
      ),
    ),
    _Faq(
      question: 'How to delete pages from a book?',
      answer: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text:
                  'From the Collection Books Screen, tap on the book you want to edit. You will then enter the Book Overview Screen. Long-press the page you want to delete and drag it onto the ',
            ),
            WidgetSpan(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  constraints: const BoxConstraints(
                      minHeight: 12,
                      maxHeight: 16,
                      minWidth: 96,
                      maxWidth: 128),
                  child: const Icon(
                    Icons.delete,
                    size: 16,
                  ),
                ),
                alignment: PlaceholderAlignment.middle),
            const TextSpan(
                text:
                    ' bar appeared at the bottom. When the bar turns red, release the page to delete.'),
          ],
        ),
      ),
    ),
    const _Faq(
      question: 'How to reorder pages in a book?',
      answer: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  'From the Collection Books Screen, tap on the book you want to edit. You will then enter the Book Overview Screen. Click the ',
            ),
            WidgetSpan(
              child: Icon(
                Icons.swap_calls,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text:
                  ' button at the top bar to enter the Page Reorder Screen. From there, long-press and drag the pages vertically to reorder them.',
            ),
          ],
        ),
      ),
    ),
    const _Faq(
      question: 'How to edit pages in a book / edit items in a page?',
      answer: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  'From the Collection Books Screen, tap on the book you want to edit. You will then enter the Book Overview Screen. Click the page you want to edit to enter the Page Slideshow Screen. From there, you can also swipe horizontally to navigate to other pages. Finally, click the ',
            ),
            WidgetSpan(
              child: Icon(
                Icons.edit,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text:
                  ' button at the top bar to enter the Page Editing Screen. From there, you can add text and images to the page. Please feel free to utilize different tools located at the top toolbar to make the page look nice! After you complete editing, remember to press the ',
            ),
            WidgetSpan(
              child: Icon(
                Icons.save,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: ' button at the top bar to save your changes.',
            ),
          ],
        ),
      ),
    ),
    const _Faq(
      question:
          'How to view all image items / image items of a specific category in a book?',
      answer: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text:
                    'From the Collection Books Screen, tap on the book you want to share. You will then enter the Book Overview Screen. From there, click the '),
            WidgetSpan(
              child: Icon(
                Icons.dashboard_rounded,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
                text:
                    ' button at the top bar. Select either "Card" or "List" to enter the corresponding view, then all image items in the book will be showed. To filter the image items by their category, press the '),
            WidgetSpan(
              child: Icon(
                Icons.filter_alt_outlined,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
                text:
                    ' button at the top bar and select the category you want to show (or "All" if you want to remove the previously selected filter).'),
          ],
        ),
      ),
    ),
    const _Faq(
      question:
          'How to change the name, category and other information of an item?',
      answer: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text:
                    'From the Collection Books Screen, tap on the book you want to share. You will then enter the Book Overview Screen. From there, click the '),
            WidgetSpan(
              child: Icon(
                Icons.dashboard_rounded,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
                text:
                    ' button at the top bar. Select either "Card" or "List" to enter the corresponding view, then all image items in the book will be showed. Click the item you want to edit to enter the editing form. After you complete editing, remember to press the '),
            WidgetSpan(
              child: Icon(
                Icons.save,
                size: 20,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(text: ' button at the top bar to save your changes.'),
          ],
        ),
      ),
    ),
    _Faq(
      question:
          'How to search for image items in all books by its name or category?',
      answer: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Tap the ',
            ),
            WidgetSpan(
              child: Column(
                children: const [
                  Icon(
                    Icons.search,
                    size: 12.0,
                    color: Colors.black54,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(fontSize: 8, color: Colors.black54),
                  )
                ],
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            const TextSpan(
                text:
                    ' tab at the bottom navigation bar to enter the Search Screen. From there, click the "Name" or "Category" toggle to search by the corresponding property. For name search, click on the input field and type the name. For category search, click on the dropdown menu and select the category. To clear the search terms, press the '),
            WidgetSpan(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      'Clear Search',
                      style:
                          TextStyle(color: theme?.primaryColor, fontSize: 12),
                    ),
                  ),
                ),
                alignment: PlaceholderAlignment.middle),
            const TextSpan(
              text: ' button at the top bar.',
            ),
          ],
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    setState(() {
      theme = Theme.of(context);
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('FAQ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            for (int i = 0; i < faqs.length; ++i)
              ExpansionTile(
                key: PageStorageKey(i),
                title: Text(faqs[i].question),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 5),
                children: [ListTile(title: faqs[i].answer)],
              ),
            const Divider(
              height: 100,
              thickness: 2,
              color: Colors.black,
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Contact Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Should you have any question regarding Kioku, please send us an email at ',
                  ),
                  WidgetSpan(
                    child: SelectableText(
                      'kpangaa@connect.ust.hk',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      onTap: () async {
                        try {
                          await launch(Mailto(
                                  to: ['kpangaa@connect.ust.hk'],
                                  subject: '[Kioku] Questions',
                                  body: 'I have a question about Kioku!')
                              .toString());
                        } catch (e) {
                          await Clipboard.setData(const ClipboardData(
                              text: 'kpangaa@connect.ust.hk'));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email copied!')));
                        }
                      },
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ));
  }
}

class _Faq {
  final String question;
  final Widget answer;

  const _Faq({required this.question, required this.answer});
}
