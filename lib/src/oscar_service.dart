import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class OscarService {
  static Database? _db;
  static Logger logger = Logger();

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "data/oscars_data.db");

    var exists = await databaseExists(path);

    if (!exists) {
      logger.d("Creating a copy of the database from assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(
        join("assets", "data/oscars_data.db"),
      );
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      logger.d("Database already exists on the device.");
    }

    return await openDatabase(path, readOnly: true);
  }

  static Future<List<Map<String, dynamic>>> getOscarsByImdbId(
    String imdbId,
  ) async {
    final db = await database;
    if (imdbId.isEmpty) {
      return [];
    }

    return await db.query(
      'oscars',
      where: 'FilmId LIKE ? AND Winner = 1',
      whereArgs: ['%$imdbId%'],
    );
  }
}
