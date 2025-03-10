import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2;

  static const folderTable = 'folder_table';
  static const columnFolderId = '_id';
  static const columnFolderName = 'folderName';
  static const columnTime = 'time';

  static const cardTable = 'card_table';
  static const columnCardId = '_cardId';
  static const columnCardName = 'name';
  static const columnSuit = 'suit';
  static const columnImgUrl = 'imgUrl';
  static const cardFolderID = 'folderid';
  late Database _db;
// this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $folderTable (
      $columnFolderId INTEGER PRIMARY KEY,
      $columnFolderName TEXT NOT NULL,
      $columnTime DATETIME DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await db.execute(''' 
      CREATE TABLE $cardTable (
      $columnCardId INTEGER PRIMARY KEY,
      $columnCardName TEXT NOT NULL,
      $columnSuit TEXT NOT NULL,
      $columnImgUrl TEXT NOT NULL,
      $cardFolderID INTEGER NOT NULL,
      FOREIGN KEY ($cardFolderID) REFERENCES $folderTable ($columnFolderId) ON DELETE CASCADE
      );
    ''');
      await db.insert(folderTable, {columnFolderId: 1, columnFolderName: "Hearts"});
  }

// Helper methods
// Inserts a row in the database where each key in the
//Map is a column name
// and the value is the column value. The return value
//is the id of the
// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(folderTable, row);
  }
  Future<int> insertCard(Map<String, dynamic> row) async {
    return await _db.insert(cardTable, row);
  }

// All of the rows are returned as a list of maps, where each map is
// a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(folderTable);
  }

// All of the methods (insert, query, update, delete) can also be done using
// raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $folderTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> queryCardRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $cardTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  /*Future<String>*/ getCardName(int id) async {
    print(await _db.rawQuery('SELECT $columnCardId FROM $cardTable'));
    //return name;
  }

  Future<List<Map<String, dynamic>>> queryCardsByFolderId(int folderId) async {
    return await _db.query(
      cardTable,
      where: '$cardFolderID = ?',
      whereArgs: [folderId],
    );
  }

/*// We are assuming here that the id column in the map is set. The other
// column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

// Deletes the row specified by the id. The number of affected rows is
// returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }*/
}