import 'package:flutter/material.dart';
import 'transaction_type_screen.dart';  // transaction_type_screen.dart 파일을 import

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
          // 메인 영역 (수입, 지출, 합계 영역)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('수입', style: TextStyle(fontSize: 16, color: Colors.blue)),
                    Text('0', style: TextStyle(fontSize: 24, color: Colors.blue)),
                  ],
                ),
                Column(
                  children: [
                    Text('지출', style: TextStyle(fontSize: 16, color: Colors.red)),
                    Text('0', style: TextStyle(fontSize: 24, color: Colors.red)),
                  ],
                ),
                Column(
                  children: [
                    Text('합계', style: TextStyle(fontSize: 16)),
                    Text('0', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
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
