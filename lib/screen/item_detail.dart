import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ItemDetailScreen extends StatefulWidget {
  static String nameField = 'name';

  final int id;
  const ItemDetailScreen(this.id, {Key? key}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: const [
          TextButton(onPressed: null, child: Text('Save')),
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
                child: Image.network('https://picsum.photos/1980/1080'),
              ),
            ),
          ),
          // ------------------------- The Form ---------------------------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: ItemDetailScreen.nameField,
                    initialValue: 'Beach',
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
                      name: 'date',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'Date & Time',
                      ),
                      initialValue: DateTime.now(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FormBuilderFilterChip(
                      name: 'categories',
                      spacing: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Select many options',
                      ),
                      options: const [
                        FormBuilderFieldOption(
                            value: 'Test', child: Text('Test')),
                        FormBuilderFieldOption(
                            value: 'Test 1', child: Text('Test 1')),
                        FormBuilderFieldOption(
                            value: 'Test 2', child: Text('Test 2')),
                        FormBuilderFieldOption(
                            value: 'Test 3', child: Text('Test 3')),
                        FormBuilderFieldOption(
                            value: 'Test 4', child: Text('Test 4')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FormBuilderTextField(
                      name: 'description',
                      initialValue: 'No description',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          labelText: 'Item Description',
                          hintText: 'Enter Description'),
                      onChanged: null,
                      // valueTransformer: (text) => num.tryParse(text),
                      validator: null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(5.0),
                          primary: Colors.black,
                          backgroundColor: Colors.blueAccent,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          _formKey.currentState!.reset();
                        },
                        child: const Text('Reset')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
