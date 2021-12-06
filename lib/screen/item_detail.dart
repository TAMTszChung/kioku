import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kioku/model/page_item.dart';
import 'package:kioku/provider/book.dart';
import 'package:kioku/provider/book_page.dart';
import 'package:kioku/provider/page_item.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  static String nameField = 'name';
  static String dateTimeField = 'dateTime';
  static String categoryField = 'categories';

  final PageItem item;
  const ItemDetailScreen(this.item, {Key? key}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          TextButton(
              onPressed: () async {
                setState(() {
                  saving = true;
                });

                final String? newName = _formKey
                    .currentState!.fields[ItemDetailScreen.nameField]!.value;
                final DateTime? newDateTime = _formKey.currentState!
                    .fields[ItemDetailScreen.dateTimeField]!.value;
                List<String> newCategories = widget.item.categories;
                final List<String> formCategories = _formKey.currentState!
                    .fields[ItemDetailScreen.categoryField]!.value;

                if (formCategories is List<String>) {
                  newCategories = formCategories;
                  newCategories.removeWhere((element) => element.isEmpty);
                  newCategories.sort(
                      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                }

                //update item details
                await context.read<PageItemProvider>().update(widget.item.copy(
                    name: newName,
                    categories: newCategories,
                    datetime: newDateTime));

                //set page last update time
                final pageProvider = context.read<BookPageProvider>();
                final page = pageProvider.get(widget.item.pageId);
                await pageProvider.update(page);

                //set book last update time
                final bookProvider = context.read<BookProvider>();
                final book = bookProvider.get(page.bookId);
                bookProvider.update(book);

                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.width,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: Image.memory(widget.item.data),
              ),
            ),
          ),
          // ------------------------- The Form ---------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: ItemDetailScreen.nameField,
                    initialValue: widget.item.name,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'Item Name',
                        hintText: 'Enter name'),
                    onChanged: null,
                    // valueTransformer: (text) => num.tryParse(text),
                    validator: null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FormBuilderDateTimePicker(
                      name: ItemDetailScreen.dateTimeField,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'Date & Time',
                      ),
                      initialValue: widget.item.datetime,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FormBuilderFilterChip(
                      name: ItemDetailScreen.categoryField,
                      spacing: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Choose item\'s categories',
                      ),
                      options: PageItem.categoryList
                          .map((category) => FormBuilderFieldOption(
                              value: category, child: Text(category)))
                          .toList(),
                      initialValue: widget.item.categories,
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20),
                  //   child: FormBuilderTextField(
                  //     name: 'description',
                  //     initialValue: 'No description',
                  //     decoration: InputDecoration(
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10)),
                  //         labelText: 'Item Description',
                  //         hintText: 'Enter Description'),
                  //     onChanged: null,
                  //     // valueTransformer: (text) => num.tryParse(text),
                  //     validator: null,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
