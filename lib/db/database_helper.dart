import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/item_belanja.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wishlist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        harga INTEGER,
        status TEXT,
        tanggal TEXT,
        foto TEXT
      )
    ''');
  }

  Future<int> insertItem(ItemBelanja item) async {
    final db = await instance.database;
    return await db.insert('wishlist', item.toMap());
  }

  Future<List<ItemBelanja>> getAllItems() async {
    final db = await instance.database;
    final result = await db.query('wishlist');
    return result.map((e) => ItemBelanja.fromMap(e)).toList();
  }

  Future<int> updateItem(ItemBelanja item) async {
    final db = await instance.database;
    return await db.update(
      'wishlist',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }
}
