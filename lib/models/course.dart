import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

class Course {
  Course({
    this.id = '',
    required this.name,
    required this.day,
    required this.start,
    required this.end,
    this.createdAt,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String day;
  final int start;
  final int end;
  final DateTime? createdAt;
  final String? photoUrl;

  Map<String, dynamic> toMap() => {
        'name': name,
        'day': day,
        'start': start,
        'end': end,
        'photoUrl': photoUrl,
      };

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Course(
      id: doc.id,
      name: data['name'] as String,
      day: data['day'] as String,
      start: (data['start'] as num).toInt(),
      end: (data['end'] as num).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

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
bool clash(Course a, Course b) => a.start < b.end && b.start < a.end;

// Returns names of all courses that clash with [course] on the same day.
List<String> clashNames(Course course, List<Course> allCourses) {
  return allCourses
      .where((c) => c.id != course.id && c.day == course.day && clash(course, c))
      .map((c) => c.name)
      .toList();
}

// Returns courses for [day] sorted by start time.
List<Course> coursesForDay(List<Course> allCourses, String day) {
  final list = allCourses.where((c) => c.day == day).toList();
  list.sort((a, b) => a.start.compareTo(b.start));
  return list;
}

// Total class minutes for a day.
int dayTotal(List<Course> allCourses, String day) => coursesForDay(allCourses, day)
    .fold(0, (totalSum, c) => totalSum + (c.end - c.start));

// Total class minutes for the whole week.
int weekTotal(List<Course> allCourses) => kDays.fold(0, (totalSum, d) => totalSum + dayTotal(allCourses, d));
