import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionScreen extends StatefulWidget {
  final String? transactionId; // Optional parameter for editing

  TransactionScreen({this.transactionId});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String _selectedType = 'income';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final Map<String, List<String>> _categories = {
    'income': ['급여', '부업', '용돈', '투자', '기타'],
    'expense': ['식비', '교통', '쇼핑', '생활', '기타']
  };

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _selectedType = data['type'];
          _selectedCategory = data['category'];
          _selectedDate = (data['date'] as Timestamp).toDate();
          _amountController.text = data['amount'].toString();
          _memoController.text = data['memo'];
        });
      }
    } catch (e) {
      print('Failed to load transaction: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveTransaction() async {
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
      if (widget.transactionId == null) {
        // Create a new transaction
        await FirebaseFirestore.instance.collection('transactions').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장되었습니다!")),
        );
      } else {
        // Update an existing transaction
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(widget.transactionId)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("수정되었습니다!")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  Future<void> _deleteTransaction() async {
    if (widget.transactionId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transactionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제되었습니다!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 실패: $e")),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionId == null ? "거래 내역 추가" : "거래 내역 수정"),
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
                      });
                    },
                    child: Text("수입"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'income'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'expense';
                      });
                    },
                    child: Text("지출"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == 'expense'
                          ? Colors.red
                          : Colors.grey,
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
                        if (selected) _selectedCategory = category;
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
              // 저장/취소 버튼
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
                    child: Text(widget.transactionId == null ? "저장" : "수정"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.transactionId != null
          ? FloatingActionButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("삭제 확인"),
                    content: Text("정말로 삭제하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("삭제"),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  _deleteTransaction();
                }
              },
              child: Icon(Icons.delete),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }
}
