import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Stream<QuerySnapshot> _getTransactions(DateTime start, DateTime end) {
    return _firestore
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
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
    }
  }

  void _nextMonth() {
    if (!_isCalendarView) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      });
    }
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
              child: Row(
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
            final type = transaction['type'];
            final category = transaction['category'];
            final amount = transaction['amount'];
            final date = (transaction['date'] as Timestamp).toDate();
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
              leading: Text("${date.day}일"),
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
              _selectedDay?.add(Duration(days: 1)) ?? _focusedDay.add(Duration(days: 1)),
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
