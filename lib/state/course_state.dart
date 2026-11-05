import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../repositories/photo_repository.dart';

class CourseState extends ChangeNotifier {
  CourseState(this._repo, this._photos) {
    _subscription = _repo.watchAll().listen(
      (list) {
        _courses = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _loading = false;
        _error = 'Could not load your courses.';
        notifyListeners();
      },
    );
  }

  final CourseRepository _repo;
  final PhotoRepository _photos;
  StreamSubscription<List<Course>>? _subscription;

  List<Course> _courses = [];
  bool _loading = true;
  String? _error;

  List<Course> get courses => _courses;
  bool get loading => _loading;
  String? get error => _error;

  int get totalMinutes => weekTotal(_courses);

  Future<void> add(Course course) => _repo.add(course);
  Future<void> edit(String id, Course course) => _repo.update(id, course);
  Future<void> remove(Course course) => _repo.delete(course.id);
  Future<String> uploadPhoto(File photo) => _photos.upload(photo);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
