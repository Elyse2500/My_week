import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/course_state.dart';
import 'course_form.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  String _selectedDay = kDays[0];

  void _openForm(BuildContext context, Course? course) {
    final wallet = context.read<CourseState>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<CourseState>.value(
          value: wallet,
          child: CourseForm(course: course),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Course course) async {
    final wallet = context.read<CourseState>();
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this course?'),
        content: Text(course.name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (sure == true) {
      await wallet.remove(course);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<CourseState>();

    if (wallet.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Week')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(wallet.error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (wallet.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final courses = wallet.courses;
    final dayCourses = coursesForDay(courses, _selectedDay);
    final wTotal = wallet.totalMinutes;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Week  •  ${formatDuration(wTotal)}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: kDays.map((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(day),
                    selected: day == _selectedDay,
                    onSelected: (_) => setState(() => _selectedDay = day),
                  ),
                );
              }).toList(),
            ),
          ),

          // Day total or empty message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dayCourses.isEmpty
                    ? 'No classes on $_selectedDay'
                    : 'Total: ${formatDuration(dayTotal(courses, _selectedDay))}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Course list or empty state
          Expanded(
            child: courses.isEmpty
                ? const Center(
                    child: Text(
                      'No courses yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dayCourses.length,
                    itemBuilder: (_, i) {
                      final c = dayCourses[i];
                      final names = clashNames(c, courses);
                      final hasClash = names.isNotEmpty;
                      return ListTile(
                        tileColor: hasClash ? Colors.red.shade50 : null,
                        leading: c.photoUrl == null
                            ? const Icon(Icons.book)
                            : CircleAvatar(backgroundImage: NetworkImage(c.photoUrl!)),
                        title: Text(
                          c.name,
                          style: TextStyle(
                            color: hasClash ? Colors.red.shade700 : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${clock(c.start)} – ${clock(c.end)}'),
                            if (hasClash)
                              Text(
                                'Clashes with ${names.join(', ')}',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                          ],
                        ),
                        onTap: () => _openForm(context, c),
                        onLongPress: () => _delete(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
