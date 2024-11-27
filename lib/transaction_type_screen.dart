import 'package:flutter/material.dart';
import 'income_screen.dart'; // A-003 화면 import
import 'expense_screen.dart'; // A-004 화면 import

class TransactionTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('거래 유형 선택'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 수입 화면 (A-003)으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncomeScreen()),
                );
              },
              child: Text('수입'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 지출 화면 (A-004)으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseScreen()),
                );
              },
              child: Text('지출'),
            ),
          ],
        ),
      ),
    );
  }
}
