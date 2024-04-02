// ignore_for_file: file_names

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// DBHelper is a Singleton class (only one instance)
class DBHelper {
  static const String _databaseName = 'chat.db1';
  static const int _databaseVersion = 1;

  DBHelper._();

  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  get db async {
    _database ??= await _initDatabase();
    
    return _database;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDocumentsDir.path, "databases", "chat.db");
          // await deleteDatabase(dbPath);

      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE chat_users(
                userId INTEGER PRIMARY KEY,
                username varchar(255),
                password varchar(255),
                contact varchar(255)
              )
          ''');

          await db.execute('''
            CREATE TABLE chat_messages(
              messageId INTEGER PRIMARY KEY,
              senderId INTEGER,
              receiverId INTEGER,
              messageContent text,
              timeStamp datetime,
              FOREIGN KEY (senderId) REFERENCES chat_users(userId)
            )
          ''');
          },
        ),
      );
      return winLinuxDB;

    } else {
       var dbDir = await getApplicationDocumentsDirectory();

      var dbPath = path.join(dbDir.path, _databaseName);
      
      var db = await openDatabase(
        dbPath, 
        version: _databaseVersion, 

        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE chat_users(
              userId INTEGER PRIMARY KEY,
              username varchar(255),
              password varchar(255),
              contact varchar(255)
            )
          ''');

          await db.execute('''
            CREATE TABLE chat_messages(
              messageId INTEGER PRIMARY KEY,
              senderId INTEGER,
              receiverId INTEGER,
              messageContent text,
              timeStamp datetime,
              FOREIGN KEY (senderId) REFERENCES chat_users(userId)
            )
          ''');
        }
      );

      return db;
    }
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table)
                         : db.query(table, where: where);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

    Future<int> insertData(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int userId = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return userId;
  }

  Future<void> update(String table, Map<String, dynamic> data, int id) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateData(String table, Map<String, dynamic> data, int userId) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int?> countChatUsers(int userId) async {
    final db = await this.db;
     final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM chat_users WHERE userId = ?', 
        [userId]
      )
    );
    return count;
  }

  Future<int?> count(int userId) async {
    final db = await this.db;
     final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM chat_messages WHERE userId = ?', 
        [userId]
      )
    );
    return count;
  }

  Future<List<Map<String, dynamic>>> customQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await this.db;
    return db.rawQuery(sql, arguments);
  }
}