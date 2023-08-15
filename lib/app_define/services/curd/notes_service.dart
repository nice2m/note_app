import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenedException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class CouldNotDeleteUser implements Exception {}

class CreateUserAlreadyExists implements Exception {}

class CounldNotFind implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotFindNotes implements Exception {}

class CouldNotDeleteNote implements Exception {}

class NoteService {
  Database? _db;

  Future<Iterable<DatabaseNote>>getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(noteTable);
    if (result.isEmpty) {
      throw CouldNotFindNotes();
    }
    final notes = result.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return notes;
  }

  Future<DatabaseNote>getNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(noteTable,where: '$noteId = ?',whereArgs: [noteId]);
    if (result.isEmpty) {
      throw CouldNotFindNotes();
    }
    return DatabaseNote.fromRow(result.first);
  }

  Future<int>deleteAllNote() async {
  final db = _getDatabaseOrThrow();
  return await db.delete(noteTable);
}

  Future<void> deleteNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final deletetCount =
        await db.delete(noteTable, where: '$noteId = ?', whereArgs: [noteId]);
    if (deletetCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<List<DatabaseNote>> getNotes({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    final result = await db.query(noteTable,
        where: '$userIdColumn = ?', whereArgs: [dbUser.email.toLowerCase()]);
    if (result.isEmpty) {
      throw CouldNotFindNotes();
    }
    return result.map((e) => DatabaseNote.fromRow(e)).toList();
  }

  Future<DatabaseNote> createNote(
      {required DatabaseUser owner, required String text}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    final noteId =
        await db.insert(noteTable, {userIdColumn: dbUser.id, textColumn: text});
    return DatabaseNote(
        id: noteId, userId: dbUser.id, text: text, isSyncWithCloud: false);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final count = await db.query(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);

    if (count.isEmpty) {
      throw CounldNotFind();
    } else {
      return DatabaseUser.fromRow(count.first);
    }
  }

  Future<DatabaseUser> createUser(
      {required String email, required String password}) async {
    final db = _getDatabaseOrThrow();
    final existedCount = await db.query(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);
    if (existedCount.isNotEmpty) {
      throw CreateUserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    await db.close();
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create user table
      await db.execute(createUserTable);

      // create note table
      await db.execute(createNoteTable);
    } on MissingPluginException catch (_) {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncWithCloud;

  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncWithCloud =
            (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'note.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncWithCloudColumn = "is_sync_with_cloud";
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';

class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'DatabaseUser Id  = $id,email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
