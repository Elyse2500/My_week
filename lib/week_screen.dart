import 'package:flutter/material.dart';
import 'data.dart';
import 'course_form.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  String _selectedDay = kDays[0];

  void _refresh() => setState(() {});

  Future<void> _openForm([Map<String, dynamic>? course]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseForm(course: course, onSaved: _refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = coursesForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Week  •  ${formatDuration(weekTotal())}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                courses.isEmpty
                    ? 'No classes on $_selectedDay'
                    : 'Total: ${formatDuration(dayTotal(_selectedDay))}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Course list
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (_, i) {
                final c = courses[i];
                final names = clashNames(c);
                final hasClash = names.isNotEmpty;
                return ListTile(
                  tileColor: hasClash ? Colors.red.shade50 : null,
                  title: Text(
                    c['name'],
                    style: TextStyle(
                      color: hasClash ? Colors.red.shade700 : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${clock(c['start'])} – ${clock(c['end'])}'),
                      if (hasClash)
                        Text(
                          'Clashes with ${names.join(', ')}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                    ],
                  ),
                  onTap: () => _openForm(c),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
