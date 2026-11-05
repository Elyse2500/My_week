/*
  Translation Table:
  MoMo Wallet       | What it is              | Example: bus booking     | Yours (Course Planner)
  ------------------+-------------------------+--------------------------+------------------------
  Txn, txn.dart     | Your model              | Booking, booking.dart    | Course, data.dart
  txn collection    | Your Firestore coll.    | bookings                 | courses collection
  TxnRepository     | Your repository         | BookingRepository        | CourseRepository
  WalletState       | Your state class        | BookingState             | CourseState
  balance           | Your computed value     | upcomingCount            | totalHours / totalCredits
  WalletScreen      | Your list screen        | BookingsScreen           | WeekScreen
  TxnForm           | Your form screen        | BookingForm              | CourseForm
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyWeekApp());
}

class MyWeekApp extends StatelessWidget {
  const MyWeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const AuthGate(),
    );
  }
}
