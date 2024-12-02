import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String _selectedType = 'income'; // 기본값: 수입
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  // 분류 항목
  final Map<String, List<String>> _categories = {
    'income': ['급여', '부업', '용돈', '투자', '기타'],
    'expense': ['식비', '교통', '쇼핑', '생활', '기타']
  };

  // 날짜 선택
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 저장 로직
  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 필드를 입력해주세요!")),
      );
      return;
    }

    final data = {
      'type': _selectedType,
      'date': Timestamp.fromDate(_selectedDate),
      'amount': int.parse(_amountController.text),
      'category': _selectedCategory,
      'memo': _memoController.text,
    };

    try {
      await FirebaseFirestore.instance.collection('transactions').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장되었습니다!")),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main', // 이동할 경로
        (route) => false, // 기존 화면 스택 제거
        arguments: {'initialIndex': 0}, // BudgetScreen 탭 인덱스 전달
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("거래 내역 추가"),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 수입/지출 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'income';
                        _selectedCategory = ''; // 선택 초기화
                      });
                    },
                    child: Text("수입"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'income' ? Colors.blue : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'expense';
                        _selectedCategory = ''; // 선택 초기화
                      });
                    },
                    child: Text("지출"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'expense' ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 날짜 선택
              Row(
                children: [
                  Text("날짜: "),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      "${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 금액 입력
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "금액"),
              ),
              SizedBox(height: 20),
              // 분류 선택
              Text("분류:"),
              Wrap(
                spacing: 10.0,
                children: _categories[_selectedType]!.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = selected ? category : '';
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // 메모 입력
              TextField(
                controller: _memoController,
                decoration: InputDecoration(labelText: "메모"),
              ),
              SizedBox(height: 20),
              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("취소"),
                  ),
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    child: Text("저장"),
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
