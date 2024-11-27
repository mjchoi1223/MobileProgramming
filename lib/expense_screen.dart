import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지출 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '금액'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: '카테고리'),
            ),
            TextField(
              controller: memoController,
              decoration: InputDecoration(labelText: '메모'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 취소
                  },
                  child: Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'type': 'expense',
                      'amount': int.parse(amountController.text),
                      'category': categoryController.text,
                      'date': DateTime.now().toString().split(' ')[0],
                      'memo': memoController.text,
                    }); // 지출 데이터 반환
                  },
                  child: Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
