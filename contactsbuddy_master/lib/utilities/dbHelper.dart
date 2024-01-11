import 'dart:io';

import 'package:contactsbuddy_master/models/contactModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final String _dbName = "Contact.db";
  final int _dbVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDB();
    return _db;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String dbPath = join(dir.path, _dbName);
    return await openDatabase(dbPath,
        version: _dbVersion, onCreate: _onCreateDb);
  }

  // Creating table
  Future<void> _onCreateDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Contact.tblName}(
    ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${Contact.colTitle} TEXT,
    ${Contact.colDate} TEXT,
    ${Contact.colPriority} TEXT,
    colIsDone BOOLEAN
    )
    ''');
    print("db create called");
  }

  // for checking is done
  // Future<bool> isDone(Contact contact) async {
  //   Database? db = await this.db;
  //   return await db!.rawQuery(
  //     "SELECT colIsDone FROM ${Contact.tblName} WHERE ${Contact.colId} LIKE ${}"
  //   );
  // }

  // Inserting contacts
  Future<int> insertContact(Contact contact) async {
    Database? db = await this.db;
    return await db!.insert(Contact.tblName, contact.toMap());
  }

  // Fetching the contacts
  Future<List<Contact>> fetchContacts(String contactName) async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> contacts = await db!.rawQuery(
        "SELECT * FROM ${Contact.tblName} WHERE ${Contact.colTitle} LIKE '$contactName%'");

    final List<Contact> contactsList = contacts.isEmpty
        ? []
        : contacts.map((e) => Contact.fromMap(e)).toList();
    contactsList
        .sort((contactA, contactB) => contactA.date!.compareTo(contactB.date!));
    return contactsList;
  }

  // Querying all contacts
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(Contact.tblName);
    return result;
  }

  // Updating the contacts
  Future<int> updateContact(Contact contact) async {
   
    Database? db = await this.db;
    return await db!.update(Contact.tblName, contact.toMap(),
        where: '${Contact.colId} = ?', whereArgs: [contact.id]);
  }

  // Deleting the contacts
  Future<int> deleteContact(int id) async {
    Database? db = await this.db;
    return await db!.delete(Contact.tblName,
        where: '${Contact.colId} = ?', whereArgs: [id]);
  }
}
