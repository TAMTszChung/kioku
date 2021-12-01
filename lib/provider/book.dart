import 'package:flutter/material.dart';
import 'package:kioku/model/book.dart';
import 'package:kioku/provider/data.dart';

class BookProvider extends DataProvider {
  BookProvider._internal() : super(tableName: 'Book', model: BookModel());

  static final _instance = BookProvider._internal();

  factory BookProvider() => _instance;

  List<Book> _books = [];

  List<Book> get books => [..._books];

  @override
  Future fetch() async {
    super.fetch();
    // TODO: set _books
    _books = [Book(color: Colors.blue)];
    notifyListeners();
  }
}
