import 'package:flutter/material.dart';
import 'budget_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BudgetScreen(), // 가계부 메인 화면
    );
  }
}
