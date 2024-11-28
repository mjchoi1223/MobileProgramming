import 'package:flutter/material.dart';
import 'income_screen.dart'; // 수입 추가 화면
import 'expense_screen.dart'; // 지출 추가 화면

class TransactionTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가계부'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 수입, 지출 버튼을 네모난 박스 모양으로 만들기
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0), // 상단 간격 조정
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15), // 버튼 높이 축소
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // 수입 추가 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IncomeScreen()),
                        );
                      },
                      child: Text('수입', style: TextStyle(fontSize: 16)), // 텍스트 크기 조정
                    ),
                  ),
                  SizedBox(width: 30), // 버튼 간 간격 확장
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15), // 버튼 높이 축소
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // 지출 추가 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExpenseScreen()),
                        );
                      },
                      child: Text('지출', style: TextStyle(fontSize: 16)), // 텍스트 크기 조정
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
