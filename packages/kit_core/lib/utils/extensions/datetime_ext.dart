extension DateTimeExt on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth =>
      DateTime(year, month + 1).subtract(const Duration(milliseconds: 1));

  /// "2h ago", "3d ago", "just now", etc. Pass [labels] to localize.
  String timeAgo([TimeAgoLabels labels = const TimeAgoLabels()]) {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return labels.justNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${labels.minutesAgo}';
    if (diff.inHours < 24) return '${diff.inHours}${labels.hoursAgo}';
    if (diff.inDays < 7) return '${diff.inDays}${labels.daysAgo}';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}${labels.weeksAgo}';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}${labels.monthsAgo}';
    return '${(diff.inDays / 365).floor()}${labels.yearsAgo}';
  }
}

/// Suffixes used by [DateTimeExt.timeAgo]. Override to localize.
class TimeAgoLabels {
  const TimeAgoLabels({
    this.justNow = 'just now',
    this.minutesAgo = 'm ago',
    this.hoursAgo = 'h ago',
    this.daysAgo = 'd ago',
    this.weeksAgo = 'w ago',
    this.monthsAgo = 'mo ago',
    this.yearsAgo = 'y ago',
  });

  final String justNow;
  final String minutesAgo;
  final String hoursAgo;
  final String daysAgo;
  final String weeksAgo;
  final String monthsAgo;
  final String yearsAgo;
}
