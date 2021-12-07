import 'package:flutter/material.dart';
import 'package:kioku/component/molecule/image_item_card.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  final String title = 'Search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //0: search name 1:search category
  int _searchMode = 0;
  String? _searchedName;
  String _searchedCategory = 'All';

  List<PageItem> items = [];

  List<PageItem> getCurrentItem() {
    if (_searchMode == 0) {
      if (_searchedName == null) {
        return items;
      }
      if (_searchedName!.isEmpty) {
        return items;
      }
      RegExp regex = RegExp(_searchedName!, caseSensitive: false);

      return items.where((item) {
        if (item.name == null) {
          return false;
        } else {
          if (regex.hasMatch(item.name!)) {
            return true;
          }
        }
        return false;
      }).toList();
    } else {
      if (_searchedCategory == 'All') {
        return items;
      } else {
        return items
            .where((item) => item.categories.contains(_searchedCategory))
            .toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    items = context
        .watch<PageItemProvider>()
        .items
        .map((item) => item.copy())
        .toList();
    items.removeWhere((item) => item.type == PageItemType.TEXTBOX);
    setState(() {
      items = items;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  _searchedName = null;
                  _searchedCategory = 'All';
                });
              },
              child: const Text('Clear Search'))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Seach By:   '),
                  ToggleSwitch(
                    initialLabelIndex: _searchMode,
                    minWidth: 80.0,
                    fontSize: 12,
                    cornerRadius: 15.0,
                    totalSwitches: 2,
                    labels: const ['Name', 'Category'],
                    onToggle: (index) {
                      setState(() {
                        _searchMode = index;
                      });
                    },
                  ),
                ],
              ),
              if (_searchMode == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    initialValue: _searchedName,
                    decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        helperText: 'Enter an item name to search',
                        hintText: 'Search...',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10)),
                    onChanged: (text) {
                      setState(() {
                        _searchedName = text;
                      });
                    },
                  ),
                ),
              if (_searchMode == 1)
                DropdownButton<String>(
                  value: _searchedCategory,
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
                    setState(() {
                      _searchedCategory = newValue;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'All',
                      child: Text(
                        'All',
                      ),
                    ),
                    ...PageItem.categoryList.map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                        ),
                      ),
                    )
                  ],
                ),
              Expanded(
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  mainAxisSpacing: 40,
                  crossAxisCount: 2,
                  children:
                      getCurrentItem().map((i) => ImageItemCard(i)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
