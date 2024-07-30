import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabit();
    // TODO: implement initState
    super.initState();
  }

  final TextEditingController textEditingController = TextEditingController();

  void changeHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabit(Habit habit) {
    textEditingController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textEditingController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textEditingController.text;
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);
                    Navigator.pop(context);

                    textEditingController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    textEditingController.clear();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  void deleteHabit(Habit habit) {
    print("hello");
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure you want to delete?"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textEditingController,
                decoration:
                    const InputDecoration(hintText: "Create a New Habit"),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    String newHabitName = textEditingController.text;

                    context.read<HabitDatabase>().addHabit(newHabitName);
                    Navigator.pop(context);

                    textEditingController.clear();
                  },
                  child: const Text("Save"),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);

                    textEditingController.clear();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewHabit();
        },
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: _buildHabitList(),
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 10),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          final habit = currentHabits[index];
          bool isCompletedToday = isHabitCompletedToday(habit.completeDays);
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => changeHabitOnOff(value, habit),
            editHabit: (context) => editHabit(habit),
            deleteHabit: (context) => deleteHabit(habit),
          );
        });
  }
}
