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
  int totalBudget=0;
  DateTime _selectedMonth = DateTime.now(); // 현재 선택된 월
  TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fetchTotalBudget(); // Firestore에서 총 예산 가져오기
    _fetchTotalExpense(); // Firestore에서 지출 합계를 가져오는 메서드 호출
  }


  // Firestore에서 총 예산(total_budget) 가져오기
  Future<void> _fetchTotalBudget() async {

      // Firestore의 'budgets' 컬렉션에서 총 예산 값 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docSnapshot = snapshot.docs
            .first; //유저를 구분하지 않기에 일단은 첫번째 문서의 값으로 테스트 하는 코드
        final data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          totalBudget = data['month']['total_budget']; // Firestore에서 가져온 값 할당
          _budgetController.text = totalBudget.toString(); // TextField에 값 반영
        });
      }

  }

  // Firestore에서 총 예산(total_budget) 업데이트
  Future<void> _updateTotalBudget() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('budgets')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docSnapshot = snapshot.docs.first; // 첫 번째 문서 선택
      final docRef = docSnapshot.reference;

      await docRef.update({
        'month.total_budget': totalBudget,
      });

      print("Total budget updated successfully.");
    }
  }

  // 예산 수정 후 저장
  void _saveBudget() {
    setState(() {
      totalBudget = int.tryParse(_budgetController.text) ?? totalBudget; // 입력 값 파싱
    });
    _updateTotalBudget(); // Firestore에 업데이트
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

      // 일단 firestore의 데이터 가져온뒤, 필터링으로 수정(두개 이상의 조건은 복합 인덱스 생성 필요)
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('type', isEqualTo: 'expense') // 지출 내역 필터링 (type만 필터링)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found.');
        setState(() {
          totalExpense = 0; // 데이터가 없으면 0으로 설정
        });
        return;
      }

      //날짜 필터링
      final filteredDocs = snapshot.docs.where((doc) {
        final date = (doc['date'] as Timestamp).toDate();
        return date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
      }).toList();

      // 필터링된 문서 출력(테스트 용)
      for (var doc in filteredDocs) {
        print('Filtered Document: ${doc.data()}');
      }

      // 총 지출 합산
      int total = filteredDocs.fold(0, (sum, doc) {
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
                  GestureDetector(
                    onTap: () {
                      // 텍스트 클릭 시 수정 가능하게 하기 위해 TextField로 바꿈
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('예산 수정'),
                            content: TextField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '예산 입력',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // 예산 저장 후 Dialog 닫기
                                  _saveBudget();
                                  Navigator.of(context).pop();
                                },
                                child: Text('저장'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 취소 시 Dialog 닫기
                                  Navigator.of(context).pop();
                                },
                                child: Text('취소'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      '$totalBudget 원', // 예산 값 표시
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  )
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
                  widthFactor: (totalExpense / (totalBudget == 0 ? 1 : totalBudget)).clamp(0.0, 1.0), // 예산 대비 지출 비율
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
                totalBudget == 0
                    ? '0%'  // totalBudget이 0일 경우 0%로 표시
                    : '${(totalExpense / totalBudget * 100).toStringAsFixed(1)}%', // 지출 비율 퍼센트
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