import 'dart:async';
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart' show join;
import "package:path_provider/path_provider.dart" show getApplicationDocumentsDirectory;
import "dart:io";

class DatabaseHelper {
  
  static final _databaseName = "product_db.db";
  static final _databaseVersion = 1;

  static final table = "product";

  static final columnId = "id";
  static final columnName = "nama";
  static final columnHarga = "harga";
  static final columnDesc = "desc";
  static final columnImg = "img";

  // Make this singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, _databaseName);
    return await openDatabase(
        path, version: _databaseVersion,
        onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE $table(
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnHarga INTEGER NOT NULL,
        $columnDesc TEXT NOT NULL,
        $columnImg BLOB
      )
      '''
    );
  }

// Helper Methods
Future<int> insert(Map<String, dynamic> row) async {
  Database db = await instance.database;
  return await db.insert(table, row);
}

Future<int> update(Map<String, dynamic> row) async {
  Database db = await instance.database;
  int id = row[columnId];
  return await db.update(table,row,where: '$columnId = ? ', whereArgs: [id]);
}

Future<List<Map<String, dynamic>>> queryAllRows() async {
  Database db = await instance.database;
  return await db.query(table);
}

Future<int> delete(int id) async {
  Database db = await instance.database;
  return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
}

}