import 'dart:async';

import 'package:flutter/services.dart';
import 'package:note/app_define/debug/dev_tool.dart';
import 'package:note/app_define/services/curd/curd_excpetions.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class NoteService {
  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance();
  factory NoteService() => _shared;

  Database? _db;
  List<DatabaseNote> _notes = [];
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;
  List<DatabaseNote> get allNotesRaw {
    return _notes;
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser catch (_) {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    await getNote(noteId: note.id);
    final db = await _getDatabaseOrThrow();
    final updateCount = await db.update(noteTable, {textColumn: text},
        where: '$idColumn = ?', whereArgs: [note.id]);
    if (updateCount == 0) {
      throw CouldNotUpdateNotes();
    }
    final updateNote = await getNote(noteId: note.id);
    DevTool.log("updateNote:note.id = ${note.id},note.text = ${note.text}");
    DevTool.log("updateNote:updateNote.id = ${updateNote.id},updateNote.text = ${updateNote.text}");

    _notes.removeWhere((noteTmp) => noteTmp.id == updateNote.id);
    _notes.add(updateNote);
    _notesStreamController.add(_notes);

    return updateNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final result = await db.query(noteTable);
    final notes = result.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return notes;
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final result = await db.query(noteTable, where: '$idColumn = ?', whereArgs: [noteId]);
    if (result.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final note = DatabaseNote.fromRow(result.first);
      return note;
    }
  }

  Future<int> deleteAllNote() async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deleteCount;
  }

  Future<void> deleteNote({required int noteId}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final deletetCount =
        await db.delete(noteTable, where: '$idColumn = ?', whereArgs: [noteId]);
    if (deletetCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == noteId);
      _notesStreamController.add(_notes);
    }
  }

  Future<List<DatabaseNote>> getNotes({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
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
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    final noteId =
        await db.insert(noteTable, {userIdColumn: dbUser.id, textColumn: text});
    final note = DatabaseNote(
        id: noteId, userId: dbUser.id, text: text, isSyncWithCloud: false);

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final count = await db.query(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);

    if (count.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(count.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
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
    await _ensureDbIsOpen();
    
    final db = await _getDatabaseOrThrow();

    final deletedCount = await db.delete(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<Database> _getDatabaseOrThrow() async {
    final db = _db;
    if (db == null){
      throw  DatabaseIsNotOpenException();
    }
    else {
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

  Future<void> _ensureDbIsOpen() async {
    try {
      await open(); 
    } on DatabaseAlreadyOpenedException {
      // empty
    }
  }

  Future<Database> open() async {
    final db = _db;
    if (db != null && db.isOpen) {
      return db;
    }
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      DevTool.log('dbPath');
      DevTool.log(dbPath);

      // create user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      // cache notes
      await _cacheNotes();

      return db;
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
