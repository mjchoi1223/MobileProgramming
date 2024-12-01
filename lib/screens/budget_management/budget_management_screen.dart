import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식화를 위해 사용

class BudgetManagementScreen extends StatefulWidget {
  final String userId;

  BudgetManagementScreen({required this.userId});

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  int totalExpense = 0; // 총 지출 변수
  DateTime _selectedMonth = DateTime.now(); // 현재 선택된 월

  @override
  void initState() {
    super.initState();
    _fetchTotalExpense(); // Firestore에서 지출 합계를 가져오는 메서드 호출
  }

  // Firestore에서 지출 합계를 계산하는 메서드
  Future<void> _fetchTotalExpense() async {
    try {
      DateTime startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      DateTime endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      print('=== Fetching Total Expense ===');
      print('Selected Month: ${DateFormat('yyyy-MM').format(_selectedMonth)}');
      print('Start of Month: $startOfMonth');
      print('End of Month: $endOfMonth');

      // Firestore 쿼리 실행
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('type', isEqualTo: 'expense') // 지출 내역 필터링
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found for the given query.');
      } else {
        for (var doc in snapshot.docs) {
          print('Document Found: ${doc.data()}');
        }
      }

      // 총 지출 합산
      int total = snapshot.docs.fold(0, (sum, doc) {
        return sum + (doc['amount'] as int);
      });

      print('Total Expense Calculated: $total');

      // 상태 업데이트
      setState(() {
        totalExpense = total;
      });
    } catch (e) {
      print('Error fetching total expense: $e');
    }
  }


  // 이전 월로 이동
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _fetchTotalExpense(); // 새로운 월에 따라 데이터 갱신
  }

  // 다음 월로 이동
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _fetchTotalExpense(); // 새로운 월에 따라 데이터 갱신
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예산 관리'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 월 이동
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: _previousMonth, // 이전 월로 이동
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(_selectedMonth), // 현재 선택된 월 표시
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _nextMonth, // 다음 월로 이동
                ),
              ],
            ),
            SizedBox(height: 16),
            // 상단 예산 정보
            Center(
              child: Column(
                children: [
                  Text(
                    '총 예산',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1,000,000', // 임시 예산 데이터
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 총 지출과 퍼센트 바
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 지출',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${totalExpense.toString()} 원', // Firestore에서 가져온 총 지출 데이터
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            // 지출 비율 표시
            Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (totalExpense / 1000000).clamp(0.0, 1.0), // 예산 대비 지출 비율
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(totalExpense / 1000000 * 100).toStringAsFixed(1)}%', // 지출 비율 퍼센트
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),
            // 친구 목록
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '친구 목록',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    // 친구 추가 기능 구현
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  '친구가 없습니다',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
