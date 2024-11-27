import 'package:flutter/material.dart';
import 'budget_screen.dart';

void main() {
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
