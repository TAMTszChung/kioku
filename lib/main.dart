import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:kioku/screen/book_overview.dart';
import 'package:kioku/screen/book_slideshow.dart';
import 'package:kioku/screen/cover_edit.dart';
import 'package:kioku/screen/home.dart';
import 'package:kioku/screen/item_detail.dart';
import 'package:kioku/screen/page_edit.dart';
import 'package:kioku/screen/page_reorder.dart';
import 'package:kioku/screen/search.dart';
import 'package:kioku/screen/share.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookProvider()),
          ChangeNotifierProvider(
              create: (context) =>
                  BookPageProvider(context.read<BookProvider>())),
          ChangeNotifierProvider(
              create: (context) =>
                  PageItemProvider(context.read<BookPageProvider>())),
        ],
        child: MaterialApp(
          title: 'Kioku',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFAFAFA),
                iconTheme: IconThemeData(color: Colors.black),
                elevation: 0.5,
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'sans-serif',
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
          home: const AppScreen(title: 'kioku'),
          onGenerateRoute: (settings) {
            final args = settings.arguments;
            switch (settings.name) {
              case '/item_detail':
                if (args is! PageItem) return null;
                return MaterialPageRoute(builder: (context) {
                  return ItemDetailScreen(args);
                });
              case '/book_slideshow':
                if (args is! int && args is! Iterable<int>) return null;
                return MaterialPageRoute(builder: (context) {
                  return BookSlideshowPage(args);
                });
              case '/page_reorder':
                if (args is! int) return null;
                return MaterialPageRoute(builder: (context) {
                  return PageReorderScreen(args);
                });
              case '/cover_edit':
                if (args is! int) return null;
                return MaterialPageRoute(builder: (context) {
                  return CoverEditPage(args);
                });
              case '/page_edit':
                if (args is! int) return null;
                return MaterialPageRoute(
                    builder: (context) {
                      return PageEditPage(args);
                    },
                    fullscreenDialog: true);
              case '/book_overview':
              default:
                if (args is! int) return null;
                return MaterialPageRoute(builder: (context) {
                  return BookOverview(args);
                });
            }
          },
        ));
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    ShareScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Collection Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Share',
          ),
        ],
        currentIndex: _selectedIndex,
        elevation: 8.0,
        iconSize: 20,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
