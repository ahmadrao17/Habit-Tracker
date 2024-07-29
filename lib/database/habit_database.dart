import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firsLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firsLaunchDate;
  }

  final List<Habit> currentHabits = [];

  Future<void> addHabit(String habit) async {
    final newHabit = Habit()..name = habit;
    await isar.writeTxn(() => isar.habits.put(newHabit));
  }

  Future<void> readHabit() async {
    List<Habit> fetchHabit = await isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(fetchHabit);

    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completeDays.contains(DateTime.now())) {
          final today = DateTime.now();

          habit.completeDays.add(
            DateTime(today.year, today.month, today.day),
          );
        } else {
          habit.completeDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        await isar.habits.put(habit);
      });
    }
    readHabit();
  }

  Future<void> updateHabitName(int id, String name) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = name;
        await isar.habits.put(habit);
      });
    }
    readHabit();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    readHabit();
  }
}
