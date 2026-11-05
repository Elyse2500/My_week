import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class CourseRepository {
  CourseRepository(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _courses =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('courses');

  Stream<List<Course>> watchAll() => _courses
      .orderBy('start')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Course.fromDoc).toList());

  Future<void> add(Course course) => _courses.add({
        ...course.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> update(String id, Course course) =>
      _courses.doc(id).update(course.toMap());

  Future<void> delete(String id) => _courses.doc(id).delete();

  Future<void> addSamples() async {
    final samples = [
      Course(name: 'Math',     day: 'Mon', start: 480, end: 600),
      Course(name: 'Physics',  day: 'Mon', start: 570, end: 660),
      Course(name: 'English',  day: 'Mon', start: 660, end: 720),
      Course(name: 'ICT',      day: 'Tue', start: 630, end: 750),
      Course(name: 'Dart Lab', day: 'Tue', start: 780, end: 900),
      Course(name: 'History',  day: 'Wed', start: 480, end: 570),
      Course(name: 'Biology',  day: 'Wed', start: 540, end: 660),
    ];
    final batch = FirebaseFirestore.instance.batch();
    for (final c in samples) {
      batch.set(_courses.doc(), {
        ...c.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
