import 'package:flutter/material.dart';
import 'data.dart';

class CourseForm extends StatefulWidget {
  final Map<String, dynamic>? course;
  final VoidCallback onSaved;

  const CourseForm({super.key, this.course, required this.onSaved});

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _start;
  late TextEditingController _end;
  late String _day;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _name  = TextEditingController(text: c?['name'] ?? '');
    _start = TextEditingController(text: c != null ? clock(c['start']) : '');
    _end   = TextEditingController(text: c != null ? clock(c['end'])   : '');
    _day   = c?['day'] ?? kDays[0];
  }

  @override
  void dispose() {
    _name.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  String? _validateTime(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (parseTime(v.trim()) == null) return 'Use HH:MM (e.g. 09:30)';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final s = parseTime(_start.text.trim())!;
    final e = parseTime(_end.text.trim())!;
    if (e <= s) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    if (widget.course != null) {
      widget.course!['name']  = _name.text.trim();
      widget.course!['day']   = _day;
      widget.course!['start'] = s;
      widget.course!['end']   = e;
    } else {
      timetable.add({'name': _name.text.trim(), 'day': _day, 'start': s, 'end': e});
    }
    widget.onSaved();
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Delete "${widget.course!['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      timetable.remove(widget.course);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Course' : 'Add Course'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isEdit)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Course name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _day,
                decoration: const InputDecoration(labelText: 'Day'),
                items: kDays.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _day = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _start,
                decoration: const InputDecoration(labelText: 'Start (HH:MM)'),
                validator: _validateTime,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _end,
                decoration: const InputDecoration(labelText: 'End (HH:MM)'),
                validator: _validateTime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
