import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' hide Table;
import 'notes_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {

  // 1. Create a Singleton Instance
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;


// Update your _internal constructor
  AppDatabase._internal() : super(driftDatabase(
    name: 'my_notes_db',
    web: DriftWebOptions(
      // Point to the files you MUST put in your web/ folder
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          debugPrint('Drift is missing features: ${result.missingFeatures}');
        }
      },
    ),
  ));

  @override
  int get schemaVersion => 1;

  // 2. Create helper methods for CRUD

  // ADD
  Future<int> addNote(String title, String content) async {
    return await into(notes).insert(
      NotesCompanion.insert(
        title: title,
        content: content,
      ),
    );
  }

  // READ (Reactive Stream)
  Stream<List<Note>> watchAllNotes() {
    return select(notes).watch();
  }

  // UPDATE
  Future<bool> updateNote(int id, String newContent) async {
    return await (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(content: Value(newContent)),
    ) > 0;
  }

  // DELETE
  Future<int> deleteNote(int id) async {
    return await (delete(notes)..where((t) => t.id.equals(id))).go();
  }
}