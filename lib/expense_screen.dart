import 'package:flutter/material.dart';
import 'income_screen.dart'; // 수입 추가 화면
import 'expense_screen.dart'; // 지출 추가 화면

class ExpenseScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  DateTime selectedDate = DateTime.now(); // 선택된 날짜
  String selectedRecurrence = '반복 없음'; // 선택된 주기

  // 날짜 선택 메소드
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 경고창 메소드
  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 저장 버튼 동작
  void _saveData() {
    if (amountController.text.isEmpty ||
        categoryController.text.isEmpty ||
        selectedRecurrence.isEmpty) {
      _showWarningDialog('모든 필수 항목을 입력해주세요.');
      return;
    }

    Navigator.pop(context, {
      'date': selectedDate.toLocal().toString().split(' ')[0],
      'recurrence': selectedRecurrence,
      'amount': int.parse(amountController.text),
      'category': categoryController.text,
      'memo': memoController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수입 추가'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (amountController.text.isNotEmpty ||
                categoryController.text.isNotEmpty ||
                memoController.text.isNotEmpty) {
              _showWarningDialog('입력된 내용이 사라집니다. 취소하시겠습니까?');
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 수입/지출 선택 버튼 추가
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
              // 날짜 선택
              Row(
                children: [
                  Text(
                    '날짜: ${selectedDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('날짜 선택'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 반복 주기 선택
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('반복 주기:', style: TextStyle(fontSize: 16)),
                  ListTile(
                    title: Text('반복 없음'),
                    leading: Radio<String>(
                      value: '반복 없음',
                      groupValue: selectedRecurrence,
                      onChanged: (value) {
                        setState(() {
                          selectedRecurrence = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('매일'),
                    leading: Radio<String>(
                      value: '매일',
                      groupValue: selectedRecurrence,
                      onChanged: (value) {
                        setState(() {
                          selectedRecurrence = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('매주'),
                    leading: Radio<String>(
                      value: '매주',
                      groupValue: selectedRecurrence,
                      onChanged: (value) {
                        setState(() {
                          selectedRecurrence = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('매월'),
                    leading: Radio<String>(
                      value: '매월',
                      groupValue: selectedRecurrence,
                      onChanged: (value) {
                        setState(() {
                          selectedRecurrence = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('매년'),
                    leading: Radio<String>(
                      value: '매년',
                      groupValue: selectedRecurrence,
                      onChanged: (value) {
                        setState(() {
                          selectedRecurrence = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 금액 입력
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '금액'),
              ),
              SizedBox(height: 20),
              // 카테고리 선택
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: '카테고리'),
              ),
              SizedBox(height: 20),
              // 메모 입력
              TextField(
                controller: memoController,
                decoration: InputDecoration(labelText: '메모 (선택 사항)'),
              ),
              SizedBox(height: 20),
              // 저장 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (amountController.text.isNotEmpty ||
                          categoryController.text.isNotEmpty ||
                          memoController.text.isNotEmpty) {
                        _showWarningDialog('입력된 내용이 사라집니다. 취소하시겠습니까?');
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
