import 'package:field_service_app/models/inspection.dart';
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
      clientId TEXT PRIMARY KEY,
      workOrderId TEXT NOT NULL,
      observation TEXT NOT NULL,
      condition TEXT,
      photoPath TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      capturedAt TEXT NOT NULL,
      status TEXT NOT NULL,
      serverId TEXT,
      errorMessage TEXT
    )
  ''');
  }

  Future<void> insertInspection(Inspection inspection) async {
    final db = await database;

    await db.insert(
      'inspections',
      inspection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Inspection>> getInspections() async {
    final db = await database;

    final result = await db.query('inspections', orderBy: 'capturedAt DESC');
    return result.map((item) => Inspection.fromMap(item)).toList();
  }

  Future<void> updateInspectionStatus({
    required String clientId,
    required String status,
    String? serverId,
    String? errorMessage,
  }) async {
    final db = await database;

    await db.update(
      'inspections',
      {'status': status, 'serverId': serverId, 'errorMessage': errorMessage},
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
  }
}
