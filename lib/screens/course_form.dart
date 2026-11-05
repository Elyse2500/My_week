import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/course_state.dart';

class CourseForm extends StatefulWidget {
  final Course? course;

  const CourseForm({super.key, this.course});

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _start;
  late TextEditingController _end;
  late String _day;
  bool _busy = false;
  File? _photo;

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _name  = TextEditingController(text: c?.name ?? '');
    _start = TextEditingController(text: c != null ? clock(c.start) : '');
    _end   = TextEditingController(text: c != null ? clock(c.end)   : '');
    _day   = c?.day ?? kDays[0];
  }

  @override
  void dispose() {
    _name.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() => _photo = File(picked.path));
  }

  Widget _photoPreview() {
    if (_photo != null) {
      return Image.file(_photo!, height: 180, fit: BoxFit.cover);
    }
    final saved = widget.course?.photoUrl;
    if (saved != null) {
      return Image.network(
        saved,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            const SizedBox(height: 180, child: Center(child: Icon(Icons.broken_image))),
      );
    }
    return const SizedBox.shrink();
  }

  String? _validateTime(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (parseTime(v.trim()) == null) return 'Use HH:MM (e.g. 09:30)';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final s = parseTime(_start.text.trim())!;
    final e = parseTime(_end.text.trim())!;
    if (e <= s) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    final wallet = context.read<CourseState>();
    setState(() => _busy = true);
    try {
      String? photoUrl = widget.course?.photoUrl;
      if (_photo != null) {
        photoUrl = await wallet.uploadPhoto(_photo!);
      }
      final courseObj = Course(
        id: widget.course?.id ?? '',
        name: _name.text.trim(),
        day: _day,
        start: s,
        end: e,
        photoUrl: photoUrl,
      );
      if (widget.course == null) {
        await wallet.add(courseObj);
      } else {
        await wallet.edit(widget.course!.id, courseObj);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving course: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final wallet = context.read<CourseState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Delete "${widget.course!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await wallet.remove(widget.course!);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting course: $e')),
          );
        }
      }
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
            IconButton(icon: const Icon(Icons.delete), onPressed: _busy ? null : _delete),
        ],
      ),
      body: SingleChildScrollView(
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
                initialValue: _day,
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
              const SizedBox(height: 16),
              _photoPreview(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pickPhoto(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _pickPhoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
