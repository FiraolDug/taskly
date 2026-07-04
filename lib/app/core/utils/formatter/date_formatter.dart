String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final taskDate = DateTime(date.year, date.month, date.day);

  if (taskDate == today) {
    return 'Today';
  } else if (taskDate == tomorrow) {
    return 'Tomorrow';
  } else if (taskDate.isBefore(today)) {
    return 'Overdue';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
