import 'package:flutter/material.dart';
import 'expense_screen.dart'; // 지출 추가 화면
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  DateTime selectedDate = DateTime.now(); // 선택된 날짜
  String selectedRecurrence = ''; // 선택된 주기
  String selectedCategory = ''; // 선택된 카테고리

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
  void _showWarningDialog(String message, {Function? onConfirm}) {
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
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 저장 버튼 동작
  void _saveData() async{
    if (amountController.text.isEmpty) {
      _showWarningDialog('금액을 입력해주세요.');
      return;
    } else if (selectedCategory.isEmpty) {
      _showWarningDialog('카테고리를 선택해주세요.');
      return;
    } else if (memoController.text.isEmpty) {
      _showWarningDialog('메모를 입력해주세요.');
      return;
    }

    // Firestore에 데이터 저장
    try {
      await FirebaseFirestore.instance.collection('recordtest').add({
        'date': selectedDate.toLocal().toString().split(' ')[0], // 날짜
        'type': '수입',  // 수입 고정
        'amount': int.parse(amountController.text), // 금액
        'category': selectedCategory, // 카테고리
        'note': memoController.text, // 메모
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터가 저장되었습니다.')),
      );
      Navigator.pop(context); // 이전 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 저장에 실패했습니다: $e')),
      );
    }
  }

  //   Navigator.pop(context, {
  //     'date': selectedDate.toLocal().toString().split(' ')[0],
  //     'recurrence': selectedRecurrence,
  //     'amount': int.parse(amountController.text),
  //     'category': selectedCategory,
  //     'memo': memoController.text,
  //   });
  // }

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
              _showWarningDialog('입력된 내용이 사라집니다. 취소하시겠습니까?', onConfirm: () {
                Navigator.pop(context);
              });
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
                          padding: EdgeInsets.symmetric(vertical: 15),
                          // 버튼 높이 축소
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // 수입 추가 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IncomeScreen()),
                          );
                        },
                        child: Text('수입', style: TextStyle(
                            fontSize: 16)), // 텍스트 크기 조정
                      ),
                    ),
                    SizedBox(width: 30), // 버튼 간 간격 확장
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          // 버튼 높이 축소
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // 지출 추가 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExpenseScreen()),
                          );
                        },
                        child: Text('지출', style: TextStyle(
                            fontSize: 16)), // 텍스트 크기 조정
                      ),
                    ),
                  ],
                ),
              ),
              // 날짜 선택
              Row(
                children: [
                  Text('날짜  ', style: TextStyle(fontSize: 40)),
                  GestureDetector(
                    onTap: () => _selectDate(context), // 텍스트를 눌렀을 때 날짜 선택
                    child: Text(
                      '${selectedDate.month}월 ${selectedDate.day}일',
                      style: TextStyle(fontSize: 30, color: Colors.blue),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 30),
              // 반복 주기 선택
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '주기 ',
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(width: 10), // 텍스트와 버튼 사이 간격
                  Expanded(
                    child: Wrap(
                      spacing: 8.0, // 버튼 간 간격
                      runSpacing: 8.0, // 줄 간 간격
                      children: [
                        for (var recurrence in ['매일', '매주', '매월', '매년'])
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // 선택된 버튼을 다시 누르면 해제
                                if (selectedRecurrence == recurrence) {
                                  selectedRecurrence = '';
                                } else {
                                  selectedRecurrence = recurrence;
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: selectedRecurrence == recurrence ? Colors
                                    .blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedRecurrence == recurrence
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              child: Text(
                                recurrence,
                                style: TextStyle(
                                  color: selectedRecurrence == recurrence
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  // 금액 입력
                  Row(
                    children: [
                      Text(
                        '금액 ',
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '금액 입력',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // 카테고리 선택
// 카테고리 버튼
                  Row(
                    children: [
                      Text(
                        '카테고리 ',
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          spacing: 8.0, // 버튼 간 간격
                          runSpacing: 8.0, // 줄 간 간격
                          children: ['월급', '용돈', '투자', '기타'].map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: selectedCategory == category ? Colors
                                      .blue : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedCategory == category ? Colors
                                        .blue : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: selectedCategory == category ? Colors
                                        .white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // 메모 입력
                  Row(
                    children: [
                      Text(
                        '메모 ',
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: memoController,
                          decoration: InputDecoration(
                            hintText: '메모 입력 (선택 사항)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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