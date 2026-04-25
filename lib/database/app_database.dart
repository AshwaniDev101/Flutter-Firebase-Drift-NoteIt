import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' hide Table;
import 'notes_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal()
    : super(
        driftDatabase(
          name: 'my_notes_db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
            onResult: (result) {
              if (result.missingFeatures.isNotEmpty) {
                debugPrint('Drift is missing features: ${result.missingFeatures}');
              }
            },
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  Future<int> addNote(String title, String content) async {
    return await into(notes).insert(NotesCompanion.insert(title: title, content: content));
  }

  Stream<List<Note>> watchAllNotes() {
    return select(notes).watch();
  }

  Future<Note> getNoteById(int id) {
    return (select(notes)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<bool> updateNoteFull(int id, String title, String content) async {
    return await (update(notes)..where((t) => t.id.equals(id))).write(
          NotesCompanion(title: Value(title), content: Value(content)),
        ) >
        0;
  }

  Future<bool> updateNote(int id, String newContent) async {
    return await (update(notes)..where((t) => t.id.equals(id))).write(NotesCompanion(content: Value(newContent))) > 0;
  }

  Future<int> deleteNote(int id) async {
    return await (delete(notes)..where((t) => t.id.equals(id))).go();
  }
}
