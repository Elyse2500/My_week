const List<String> kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

List<Map<String, dynamic>> timetable = [
  {'name': 'Math',     'day': 'Mon', 'start': 480, 'end': 600},  // 8:00–10:00
  {'name': 'Physics',  'day': 'Mon', 'start': 570, 'end': 660},  // 9:30–11:00  clashes with Math
  {'name': 'English',  'day': 'Mon', 'start': 660, 'end': 720},  // 11:00–12:00
  {'name': 'ICT',      'day': 'Tue', 'start': 630, 'end': 750},  // 10:30–12:30
  {'name': 'Dart Lab', 'day': 'Tue', 'start': 780, 'end': 900},  // 13:00–15:00
  {'name': 'History',  'day': 'Wed', 'start': 480, 'end': 570},  // 8:00–9:30
  {'name': 'Biology',  'day': 'Wed', 'start': 540, 'end': 660},  // 9:00–11:00  clashes with History
];

// Converts "HH:MM" to minutes since midnight. Returns null if invalid.
int? parseTime(String s) {
  final parts = s.trim().split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23) return null;
  if (m < 0 || m > 59) return null;
  return h * 60 + m;
}

// Converts minutes since midnight to "H:MM".
String clock(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '$h:${m.toString().padLeft(2, '0')}';
}

// Formats a duration in minutes as "Xh Ym".
String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

// Two courses clash when each starts before the other ends.
// Strict < means back-to-back (one ends exactly when the other starts) does NOT clash.
bool clash(Map a, Map b) => a['start'] < b['end'] && b['start'] < a['end'];

// Returns names of all courses that clash with [course] on the same day.
List<String> clashNames(Map course) {
  return timetable
      .where((c) => c != course && c['day'] == course['day'] && clash(course, c))
      .map((c) => c['name'] as String)
      .toList();
}

// Returns courses for [day] sorted by start time.
List<Map<String, dynamic>> coursesForDay(String day) {
  final list = timetable.where((c) => c['day'] == day).toList();
  list.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
  return list;
}

// Total class minutes for a day.
int dayTotal(String day) => coursesForDay(day)
    .fold(0, (sum, c) => sum + ((c['end'] as int) - (c['start'] as int)));

// Total class minutes for the whole week.
int weekTotal() => kDays.fold(0, (sum, d) => sum + dayTotal(d));
