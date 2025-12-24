import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../editor/models.dart';

part 'history_repo.g.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String input;

  @HiveField(1)
  final String output;

  @HiveField(2)
  final Map<String, dynamic> settingsJson;

  @HiveField(3)
  final DateTime createdAt;

  HistoryEntry({
    required this.input,
    required this.output,
    required this.settingsJson,
    required this.createdAt,
  });

  RefactorSettings get settings => RefactorSettings.fromJson(settingsJson);
}

class HistoryRepo {
  static Future<void> initHive() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }
    await Hive.openBox<HistoryEntry>(AppConstants.historyBoxName);
  }

  Box<HistoryEntry> get _box => Hive.box<HistoryEntry>(AppConstants.historyBoxName);

  List<HistoryEntry> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> addEntry({
    required String input,
    required String output,
    required RefactorSettings settings,
  }) async {
    final entry = HistoryEntry(
      input: input,
      output: output,
      settingsJson: settings.toJson(),
      createdAt: DateTime.now(),
    );
    await _box.add(entry);
  }

  Future<void> deleteEntry(HistoryEntry e) => e.delete();

  Future<void> clearAll() => _box.clear();
}
