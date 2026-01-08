import 'package:flutter/material.dart';

import '../models/day_consumption.dart';
import '../utils/conversion.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history});

  final List<DayConsumption> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water History'),
      ),
      body: history.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final day = history[index];
                return _HistoryRow(day: day);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop_outlined,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'No history yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Start tracking your water intake to see it here.'),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.day});

  final DayConsumption day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool metGoal = day.consumption >= day.dayGoal;
    final ratio = day.dayGoal == 0
        ? 0.0
        : (day.consumption / day.dayGoal).clamp(0.0, 1.0);
    final Color statusColor =
        metGoal ? theme.colorScheme.primary : theme.colorScheme.tertiary;
    final icon = metGoal ? Icons.check_circle_rounded : Icons.timelapse_rounded;
    final DateTime today = _stripTime(DateTime.now());
    final DateTime checkDate = _stripTime(day.dateTime);
    final bool isToday = _isSameDate(checkDate, today);
    final String statusText = metGoal
        ? 'Goal met'
        : isToday
            ? 'Keep sipping'
            : 'Goal missed';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _formatDate(day.dateTime),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(icon, color: statusColor),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${formatNumberToLiter(day.consumption)} of ${formatNumberToLiter(day.dayGoal)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              statusText,
              style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final today = _stripTime(DateTime.now());
    final checkDate = _stripTime(date);
    final yesterday = today.subtract(const Duration(days: 1));
    if (_isSameDate(checkDate, today)) {
      return 'Today';
    }
    if (_isSameDate(checkDate, yesterday)) {
      return 'Yesterday';
    }
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final weekday = weekdays[checkDate.weekday - 1];
    final month = months[checkDate.month - 1];
    return '$weekday, $month ${checkDate.day}';
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
