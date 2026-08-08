import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'field_service.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE inspections(
    clienteId TEXT PRIMARY KEY,
    workOrderId TEXT NOT NULL,
    observation TEXT NOT NULL,
    codition TEXT,
    photoPath TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    captureAt TEXT NOT NULL,
    status TEXT NOT NULL,
    serverId TEXT,
    errorMessage TEXT
    )''');
  }
}
