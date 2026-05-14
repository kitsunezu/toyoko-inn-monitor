import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Table Definitions ────────────────────────────────────────────

class PriceHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskId => text()();
  TextColumn get hotelCode => text()();
  TextColumn get hotelName => text()();
  IntColumn get price => integer()();
  TextColumn get checkin => text()(); // YYYY-MM-DD
  TextColumn get checkout => text()(); // YYYY-MM-DD
  DateTimeColumn get polledAt => dateTime()();
}

class MonitorTaskTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get paramsJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ─────────────────────────────────────────────────────

@DriftDatabase(tables: [PriceHistoryTable, MonitorTaskTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── PriceHistory queries ──

  Future<void> insertHistory(PriceHistoryTableCompanion entry) =>
      into(priceHistoryTable).insert(entry);

  Future<List<PriceHistoryTableData>> historyByTask(String taskId) =>
      (select(priceHistoryTable)
            ..where((t) => t.taskId.equals(taskId))
            ..orderBy([(t) => OrderingTerm.asc(t.polledAt)]))
          .get();

  Future<List<PriceHistoryTableData>> historyByHotel(
    String taskId,
    String hotelCode,
  ) =>
      (select(priceHistoryTable)
            ..where(
              (t) =>
                  t.taskId.equals(taskId) & t.hotelCode.equals(hotelCode),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.polledAt)]))
          .get();

  Future<int> deleteTaskHistory(String taskId) =>
      (delete(priceHistoryTable)
            ..where((t) => t.taskId.equals(taskId)))
          .go();

  // ── MonitorTask queries ──

  Future<List<MonitorTaskTableData>> allTasks() =>
      (select(monitorTaskTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> upsertTask(MonitorTaskTableCompanion entry) =>
      into(monitorTaskTable).insertOnConflictUpdate(entry);

  Future<int> deleteTask(String id) =>
      (delete(monitorTaskTable)..where((t) => t.id.equals(id))).go();
}

// ── Connection factory ───────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dir.path, 'ToyokoInnMonitor'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    final file = File(p.join(dbDir.path, 'monitor.db'));
    return NativeDatabase.createInBackground(file);
  });
}
