bool isHabitCompletedToday(List<DateTime> completedDays){
  final today = DateTime.now();

  return completedDays.any((element)=>
  element.year == today.year &&
  element.month == today.month &&
  element.day == today.day
  );
}