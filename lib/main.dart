import 'package:flutter/material.dart';
import 'week_screen.dart';

void main() => runApp(const MyWeekApp());

class MyWeekApp extends StatelessWidget {
  const MyWeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const WeekScreen(),
    );
  }
}
