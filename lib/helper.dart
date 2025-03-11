import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'my_table';
  static const columnId = '_id';
  static const columnCardUp = 'isCardUp';
  static const columnBackDesign = 'backDesign';
  static const columnFrontDesign = 'frontDesign';
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
  CREATE TABLE $table (
  $columnId INTEGER PRIMARY KEY,
  $columnCardUp INTEGER DEFAULT 0, 
  $columnBackDesign TEXT NOT NULL,
  $columnFrontDesign TEXT NOT NULL
  )
''');
  /*await db.insert(table, {
      columnId: 1,
      columnCardUp: 0, 
      columnBackDesign: 'https://i.pinimg.com/236x/90/04/5e/90045ee90ffda21b689af6a2847e6b0d.jpg',
      columnFrontDesign: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/English_pattern_ace_of_clubs.svg/800px-English_pattern_ace_of_clubs.svg.png',
    });
    await db.insert(table, {
      columnId: 2,
      columnCardUp: 0, 
      columnBackDesign: 'https://i.pinimg.com/236x/90/04/5e/90045ee90ffda21b689af6a2847e6b0d.jpg',
      columnFrontDesign: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/English_pattern_2_of_clubs.svg/800px-English_pattern_2_of_clubs.svg.png',
    });*/
    List<String> frontDesigns = [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/English_pattern_ace_of_clubs.svg/800px-English_pattern_ace_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/English_pattern_2_of_clubs.svg/800px-English_pattern_2_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/English_pattern_3_of_clubs.svg/800px-English_pattern_3_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/English_pattern_4_of_clubs.svg/800px-English_pattern_4_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/English_pattern_5_of_clubs.svg/800px-English_pattern_5_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/English_pattern_6_of_clubs.svg/800px-English_pattern_6_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/English_pattern_7_of_clubs.svg/800px-English_pattern_7_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/English_pattern_8_of_clubs.svg/800px-English_pattern_8_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/English_pattern_9_of_clubs.svg/800px-English_pattern_9_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/English_pattern_10_of_clubs.svg/800px-English_pattern_10_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/English_pattern_jack_of_clubs.svg/800px-English_pattern_jack_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/English_pattern_queen_of_clubs.svg/800px-English_pattern_queen_of_clubs.svg.png',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/English_pattern_king_of_clubs.svg/800px-English_pattern_king_of_clubs.svg.png'
    ];

    for (int i = 0; i < 13; i++) {
      await db.insert(table, {
        columnId: i + 1, 
        columnCardUp: 0, 
        columnBackDesign: 'https://i.pinimg.com/236x/90/04/5e/90045ee90ffda21b689af6a2847e6b0d.jpg',
        columnFrontDesign: frontDesigns[i],
      });
    }
  }

// Helper methods
// Inserts a row in the database where each key in the
//Map is a column name
// and the value is the column value. The return value
//is the id of the
// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

// All of the rows are returned as a list of maps, where each map is
// a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    await init();
    return await _db.query(table);
  }

// All of the methods (insert, query, update, delete) can also be done using
// raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

// We are assuming here that the id column in the map is set. The other
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
  }
}