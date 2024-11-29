import 'package:flutter/material.dart';
import 'transaction_type_screen.dart';  // transaction_type_screen.dart 파일을 import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _selectedIndex = 0;  // 하단 네비게이션의 선택된 버튼 인덱스
  DateTime _currentDate = DateTime.now();  // 현재 날짜
  late String _formattedDate; // 날짜를 표시할 형식

  @override
  void initState() {
    super.initState();
    _formattedDate = "${_currentDate.year}년 ${_currentDate.month}월"; // 날짜 형식 지정
  }

  // Firestore에서 거래 데이터 가져오기
  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    try {
      // 현재 year와 month를 문자열로 변환
      String year = _currentDate.year.toString();
      String month = _currentDate.month.toString().padLeft(2, '0'); // 두 자리 형식으로 맞춤

      // Firestore에서 date 문자열이 해당 year와 month로 시작하는 데이터 필터링
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recordtest')
          .where('date', isGreaterThanOrEqualTo: "$year-$month-01") // 해당 월의 첫날 이상
          .where('date', isLessThan: "$year-${(int.parse(month) + 1).toString().padLeft(2, '0')}-01") // 다음 월의 첫날 미만
          .get();

      // 데이터를 Map 형식으로 변환하여 반환
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('데이터 불러오기 실패: $e');
      return [];
    }
  }


  // 수입, 지출, 합계 계산
  Future<Map<String, int>> _calculateSummary() async {
    List<Map<String, dynamic>> transactions = await _fetchTransactions();
    int income = 0; // 수입
    int expense = 0; // 지출

    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        income += (transaction['amount'] as int);
      } else if (transaction['type'] == 'expense') {
        expense += (transaction['amount'] as int);
      }
    }
    return {
      'income': income,
      'expense': expense,
      'total': income - expense,
    };
  }

  // 하단 네비게이션 바에서 아이템을 선택했을 때의 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _formattedDate = "${_currentDate.year}년 ${_currentDate.month}월";
    });
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _formattedDate = "${_currentDate.year}년 ${_currentDate.month}월";
    });
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase 로그아웃
      // 로그인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // LoginScreen 이동
      );
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃에 실패했습니다. 다시 시도하세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 영역
      appBar: AppBar(
        title: Text('가계부'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              // 달력 아이콘 클릭 시 동작 (필요시 동작 추가)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜, 주기, 금액, 카테고리, 메모 입력 영역 (상단 영역 아래)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이전 달 버튼
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: _previousMonth,
                ),
                // 현재 달 표시
                Text(
                  _formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // 다음 달 버튼
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // 수입, 지출, 합계
          FutureBuilder<Map<String, int>>(
            future: _calculateSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('요약 데이터 로드 실패: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('요약 데이터가 없습니다.');
              }

              final summary = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('수입', style: TextStyle(fontSize: 16, color: Colors.blue)),
                        Text('${summary['income']}원',
                            style: TextStyle(fontSize: 24, color: Colors.blue)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('지출', style: TextStyle(fontSize: 16, color: Colors.red)),
                        Text('${summary['expense']}원',
                            style: TextStyle(fontSize: 24, color: Colors.red)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('합계', style: TextStyle(fontSize: 16)),
                        Text('${summary['total']}원', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // 거래 내역 리스트
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('데이터 불러오기 실패: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('저장된 데이터가 없습니다.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final transaction = snapshot.data![index];
                    return ListTile(
                      title: Text(
                        "날짜: ${transaction['date']} | "
                            "종류: ${transaction['type']} | "
                            "금액: ${transaction['amount']}원",
                      ),
                      subtitle: Text(
                          "카테고리: ${transaction['category']} | 메모: ${transaction['note']}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // + 버튼을 우측 하단에 배치
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 수입/지출 추가 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionTypeScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,  // + 버튼을 우측 하단에 배치
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '가계부',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '예산',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        selectedItemColor: Colors.blue, // 선택된 아이템 색상
        unselectedItemColor: Colors.black54, // 선택되지 않은 아이템 색상
        showUnselectedLabels: true,  // 선택되지 않은 아이템에도 레이블을 표시
        backgroundColor: Colors.white, // 네비게이션 바 배경색
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BudgetScreen(),
  ));
}
