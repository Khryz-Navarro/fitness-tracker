import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton class that manages the SQLite database connection
/// and provides CRUD operations for the `users` and `admins` tables.
class DatabaseHelper {
  // ── Singleton setup ─────────────────────────────────────────────────────
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ── Initialise database ─────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        goal TEXT NOT NULL,
        profile_pic_path TEXT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT NOT NULL CHECK(role IN ('client', 'admin'))
      )
    ''');

    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Seed a default admin account.
    await db.insert('admins', {
      'username': 'admin',
      'password': 'admin123',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS admins (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');

      // Seed a default admin if table was just created.
      final existing = await db.query('admins');
      if (existing.isEmpty) {
        await db.insert('admins', {
          'username': 'admin',
          'password': 'admin123',
        });
      }
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN username TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
    }
  }

  // ── CRUD Methods ────────────────────────────────────────────────────────

  /// Insert a new user row. Returns the auto-generated id.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  /// Update an existing user row by id. Returns the number of changes made.
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    int id = user['id'];
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a user row by id. Returns the number of changes made.
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns every user row where role == 'client'.
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['client'],
      orderBy: 'id DESC',
    );
  }

  /// Returns a single client by [id], or `null` if not found.
  Future<Map<String, dynamic>?> getClientById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ── Admin Authentication ────────────────────────────────────────────────

  /// Validates admin credentials. Returns the admin row if valid, null otherwise.
  Future<Map<String, dynamic>?> authenticateAdmin(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'admins',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ── Client Authentication ────────────────────────────────────────────────

  /// Validates client credentials. Returns the client row if valid, null otherwise.
  Future<Map<String, dynamic>?> authenticateClient(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ? AND role = ?',
      whereArgs: [username, password, 'client'],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
