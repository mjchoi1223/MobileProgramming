import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedMonth = DateTime.now();
  String _selectedType = 'income'; // 기본적으로 수입 선택

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    String monthKey = "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text("통계"),
      ),
      body: Column(
        children: [
          // 월 선택 및 수입/지출 선택 탭
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
                  "${_selectedMonth.year}년 ${_selectedMonth.month}월",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          ToggleButtons(
            isSelected: [_selectedType == 'income', _selectedType == 'expense'],
            onPressed: (index) {
              setState(() {
                _selectedType = index == 0 ? 'income' : 'expense';
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("수입", style: TextStyle(color: Colors.blue)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("지출", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('transactions').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final transactions = snapshot.data!.docs.where((doc) {
                  final date = (doc['date'] as Timestamp).toDate();
                  return date.year == _selectedMonth.year &&
                      date.month == _selectedMonth.month &&
                      doc['type'] == _selectedType;
                });

                final categorySums = <String, int>{};
                int totalAmount = 0;

                transactions.forEach((doc) {
                  final category = doc['category'] as String;
                  final amount = (doc['amount'] as num).toInt();
                  totalAmount += amount;
                  categorySums[category] = (categorySums[category] ?? 0) + amount;
                });

                return Column(
                  children: [
                    Text(
                      "총 ${_selectedType == 'income' ? '수입' : '지출'}: $totalAmount 원",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    if (totalAmount > 0)
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: categorySums.entries.map((entry) {
                              final percentage = (entry.value / totalAmount) * 100;
                              return PieChartSectionData(
                                value: percentage,
                                title: "${entry.key}\n${percentage.toStringAsFixed(1)}%",
                                color: _getCategoryColor(entry.key),
                              );
                            }).toList(),
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: categorySums.entries.map((entry) {
                          return ListTile(
                            title: Text(entry.key),
                            trailing: Text("${entry.value} 원"),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '급여':
        return Colors.pink;
      case '부업':
        return Colors.blue;
      case '용돈':
        return Colors.purple;
      case '투자':
        return Colors.orange;
      case '상여':
        return Colors.yellow;
      case '기타':
        return Colors.green;
      case '식비':
        return Colors.redAccent;
      case '교통':
        return Colors.lightBlue;
      case '쇼핑':
        return Colors.deepPurple;
      case '생활':
        return Colors.teal;
      case '통신':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
