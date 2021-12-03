import 'package:flutter/material.dart';
import 'package:kioku/component/atom/resizable.dart';

class PageEditPage extends StatefulWidget {
  final int id;
  const PageEditPage(this.id, {Key? key}) : super(key: key);

  @override
  State<PageEditPage> createState() => _PageEditPageState();
}

class _PageEditPageState extends State<PageEditPage> {
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: AspectRatio(
                    aspectRatio: 210 / 297,
                    child: Builder(builder: (context) {
                      final Size containerSize = MediaQuery.of(context).size;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        child: Center(
                          child: Resizable(
                            initialHeight: 200,
                            initialWidth: 200,
                            containerHeight: containerSize.height,
                            containerWidth: containerSize.width,
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
          Text('ABC'),
        ],
      ),
    );
  }
}
