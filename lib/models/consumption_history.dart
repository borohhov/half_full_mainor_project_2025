import 'day_consumption.dart';

class ConsumptionHistory {
  ConsumptionHistory({required List<DayConsumption> days})
      : _days = List<DayConsumption>.from(days) {
    _sortDescending();
  }

  final List<DayConsumption> _days;

  List<DayConsumption> get days => List.unmodifiable(_days);

  void replaceAll(Iterable<DayConsumption> days) {
    _days
      ..clear()
      ..addAll(days);
    _sortDescending();
  }

  DayConsumption ensureDay(DateTime date, {required double goal}) {
    final normalized = _asDate(date);
    final existing = _findDay(normalized);
    if (existing != null) {
      existing.dayGoal = goal;
      return existing;
    }
    final newEntry = DayConsumption(normalized, 0, goal);
    _days.add(newEntry);
    _sortDescending();
    return newEntry;
  }

  DayConsumption? _findDay(DateTime date) {
    for (final day in _days) {
      if (_isSameDay(day.dateTime, date)) {
        return day;
      }
    }
    return null;
  }

  DateTime _asDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _sortDescending() {
    _days.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
