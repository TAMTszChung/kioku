import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final String title = "Kioku";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.add),
              color: Colors.black,
            ),
          ],
        ),
        body: Center(
            child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 20,
          crossAxisCount: 2,
          children: const [
            // TODO: books
          ],
        )));
  }
}
