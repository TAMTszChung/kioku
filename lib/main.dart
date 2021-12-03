import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/screen/book_overview.dart';
import 'package:kioku/screen/cover_display.dart';
import 'package:kioku/screen/cover_edit.dart';
import 'package:kioku/screen/home.dart';
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
        ],
        child: MaterialApp(
          title: 'Kioku',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
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
        ));
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  Route? _onGenerateRoute(settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/cover_display':
        if (args is! int) return null;
        return MaterialPageRoute(builder: (context) {
          return CoveDisplayPage(args);
        });
      case '/cover_edit':
        if (args is! int) return null;
        return MaterialPageRoute(builder: (context) {
          return CoverEditPage(args);
        });
      case '/book_overview':
      default:
        if (args is! int) return null;
        return MaterialPageRoute(builder: (context) {
          return BookOverview(args);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
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
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 2:
            return SafeArea(
                child: CupertinoTabView(
                    builder: (context) {
                      return const CupertinoPageScaffold(
                        child: ShareScreen(),
                      );
                    },
                    onGenerateRoute: _onGenerateRoute));
          case 1:
            return SafeArea(
                child: CupertinoTabView(
                    builder: (context) {
                      return const CupertinoPageScaffold(
                        child: SearchScreen(),
                      );
                    },
                    onGenerateRoute: _onGenerateRoute));
          case 0:
          default:
            return SafeArea(
                child: CupertinoTabView(
                    builder: (context) {
                      return const CupertinoPageScaffold(
                        child: HomeScreen(),
                      );
                    },
                    onGenerateRoute: _onGenerateRoute));
        }
      },
    );
  }
}
