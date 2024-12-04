import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';


class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = false;

  int totalIncome = 0;
  int totalExpense = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeUserId();
    _calculateMonthlyTotals();
  }

  // Firebase에서 userId 가져오기
  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Stream<QuerySnapshot> _getTransactions(DateTime start, DateTime end) {
    return _firestore
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .where('userId', isEqualTo: userId) // userId 추가
        .orderBy('date', descending: true) // 날짜 기준 내림차순 정렬
        .snapshots();
  }

  void _toggleView() {
    setState(() {
      _isCalendarView = !_isCalendarView;
    });
  }

  void _previousMonth() {
    if (!_isCalendarView) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      });
      _calculateMonthlyTotals();
    }
  }

  void _nextMonth() {
    if (!_isCalendarView) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      });
      _calculateMonthlyTotals();
    }
  }

  void _calculateMonthlyTotals() async {
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final transactions = await _firestore
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    double income = 0;
    double expense = 0;

    for (var doc in transactions.docs) {
      final type = doc['type'];
      final amount = doc['amount'];
      if (type == 'income') {
        income += amount;
      } else if (type == 'expense') {
        expense += amount;
      }
    }

    setState(() {
      totalIncome = income.toInt();
      totalExpense = expense.toInt();
    });
  }

  void _showEditDeleteMenu(BuildContext context, DocumentSnapshot transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("수정"),
              onTap: () {
                Navigator.pop(context);
                _editTransaction(transaction);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("삭제"),
              onTap: () {
                Navigator.pop(context);
                _deleteTransaction(transaction);
              },
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(DocumentSnapshot transaction) {
    //수정 로직 추가
  }

  void _deleteTransaction(DocumentSnapshot transaction) {
    transaction.reference.delete().then((_) {
      // 수입, 지출, 합계 값 업데이트
      _calculateMonthlyTotals();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 완료")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 실패: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("가계부"),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isCalendarView)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        "${_focusedDay.year}년 ${_focusedDay.month}월",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "수입",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          Text(
                            "$totalIncome",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "지출",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          Text(
                            "$totalExpense",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "합계",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Text(
                            "${totalIncome - totalExpense}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isCalendarView ? _buildCalendarView() : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/transaction',
            arguments: {'type': 'income'}, // 기본값 또는 전달할 데이터 설정
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView() {
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    return StreamBuilder<QuerySnapshot>(
      stream: _getTransactions(startOfMonth, endOfMonth),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("이번 달 내역이 없습니다."));
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final type = transaction['type']; // income 또는 expense
            final category = transaction['category'];
            final amount = transaction['amount'];
            final date = (transaction['date'] as Timestamp).toDate();
            final memo = transaction['memo'];

            return GestureDetector(
              onLongPress: () => _showEditDeleteMenu(context, transaction),
              child: ListTile(
                title: Text(category),
                subtitle: Text(memo),
                trailing: Text(
                  (type == 'income' ? "+" : "-") + "$amount",
                  style: TextStyle(
                    color: type == 'income' ? Colors.blue : Colors.red,
                  ),
                ),
                leading: Text("${date.day}일"),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getTransactions(
              _selectedDay ?? _focusedDay,
              _selectedDay?.add(Duration(days: 1)) ??
                  _focusedDay.add(Duration(days: 1)),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("내역이 없습니다."));
              }

              final transactions = snapshot.data!.docs;

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final type = transaction['type'];
                  final category = transaction['category'];
                  final amount = transaction['amount'];
                  final memo = transaction['memo'];

                  return ListTile(
                    title: Text(category),
                    subtitle: Text(memo),
                    trailing: Text(
                      (type == 'income' ? "+" : "-") + "$amount",
                      style: TextStyle(
                        color: type == 'income' ? Colors.blue : Colors.red,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
