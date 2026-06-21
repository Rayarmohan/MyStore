import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'my_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        category TEXT
      )
    ''');
  }

  Future<int> insertCartItem(Map<String, dynamic> item) async {
    final db = await database;
    final existing = await db.query(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [item['productId']],
    );
    if (existing.isNotEmpty) {
      return await db.update(
        'cart_items',
        {'quantity': (existing.first['quantity'] as int) + (item['quantity'] as int)},
        where: 'productId = ?',
        whereArgs: [item['productId']],
      );
    }
    return await db.insert('cart_items', item);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('cart_items');
  }

  Future<int> updateCartItemQuantity(int productId, int quantity) async {
    final db = await database;
    return await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> removeCartItem(int productId) async {
    final db = await database;
    return await db.delete(
      'cart_items',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<int> clearCart() async {
    final db = await database;
    return await db.delete('cart_items');
  }
}
