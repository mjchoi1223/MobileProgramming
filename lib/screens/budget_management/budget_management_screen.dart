import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식화를 위해 사용
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetManagementScreen extends StatefulWidget {
  final String userId;

  BudgetManagementScreen({required this.userId});

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  int totalExpense = 0; // 총 지출 변수
  int totalBudget = 0; // 총 예산 변수
  DateTime _selectedMonth = DateTime.now(); // 현재 선택된 월
  TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notificationsPlugin = FlutterLocalNotificationsPlugin(); 
    _initializeNotifications();
    _fetchOrCreateBudget(); // Firestore에서 예산 가져오거나 생성
    _fetchTotalExpense(); // Firestore에서 지출 합계 가져오기
    print('UserId: ${widget.userId}');
    print('DocId: $_docId');
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('splash'); // 아이콘 설정 확인
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _notificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'budget_exceeded_channel', // 채널 ID
      'Budget Exceeded', // 채널 이름
      description: 'Notifies when the budget is exceeded', // 채널 설명
      importance: Importance.high,
    );

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 고유한 `docId` 생성 (userId + 월)
  String get _docId {
    final monthId = DateFormat('yyyy-MM').format(_selectedMonth);
    return "${widget.userId}_$monthId";
  }

  /// Firestore에서 예산 가져오기 또는 문서가 없으면 새 문서 생성
  Future<void> _fetchOrCreateBudget() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .doc(_docId)
          .get();

      if (docSnapshot.exists) {
        // 문서가 존재하면 데이터 가져오기
        final data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          totalBudget = data['total_budget'] ?? 0;
          _budgetController.text = totalBudget.toString();
        });
      } else {
        // 문서가 없으면 새 문서 생성
        await FirebaseFirestore.instance.collection('budgets').doc(_docId).set({
          'userId': widget.userId,
          'total_budget': 0, // 초기 예산값
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          totalBudget = 0;
          _budgetController.text = '0';
        });
        print('New budget document created for $_docId');
      }
    } catch (e) {
      print('Error fetching or creating budget: $e');
    }
  }

  /// Firestore에서 예산 업데이트
  Future<void> _updateTotalBudget() async {
    try {
      await FirebaseFirestore.instance.collection('budgets').doc(_docId).set({
        'userId': widget.userId,
        'total_budget': totalBudget,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Total budget for $_docId updated successfully.");
    } catch (e) {
      print('Error updating total budget: $e');
    }
  }

  /// 예산 수정 후 저장
  void _saveBudget() {
    setState(() {
      totalBudget = int.tryParse(_budgetController.text) ?? totalBudget;
    });
    _updateTotalBudget(); // Firestore에 업데이트
    if (totalExpense > totalBudget && totalBudget > 0) {
    _showBudgetExceededNotification();
    }
  }

  /// Firestore에서 총 지출 합계 계산
  Future<void> _fetchTotalExpense() async {
    try {
      DateTime startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      DateTime endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: widget.userId)
          .where('type', isEqualTo: 'expense')
          .get();

      final filteredDocs = snapshot.docs.where((doc) {
        final date = (doc['date'] as Timestamp).toDate();
        return date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
      });

      final total = filteredDocs.fold(0, (sum, doc) => sum + (doc['amount'] as int));

      setState(() {
        totalExpense = total;
      });

      if (totalExpense > totalBudget && totalBudget > 0) {
        // 마지막으로 알림이 발송된 상태인지 확인
        final prefs = await SharedPreferences.getInstance();
        final lastNotified = prefs.getBool('lastBudgetExceeded') ?? false;

        if (!lastNotified) {
          _showBudgetExceededNotification();
          prefs.setBool('lastBudgetExceeded', true);
        }
      } else {
        // 조건 만족하지 않을 때 플래그 초기화
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('lastBudgetExceeded', false);
      }
    } catch (e) {
      print('Error fetching total expense: $e');
    }
  }

  /// 이전 월로 이동
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _fetchOrCreateBudget();
    _fetchTotalExpense();
  }

  /// 다음 월로 이동
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _fetchOrCreateBudget();
    _fetchTotalExpense();
  }

  Future<void> _showBudgetExceededNotification() async {
    // 알림 활성화 상태 확인
    final prefs = await SharedPreferences.getInstance();
    final isNotificationEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!isNotificationEnabled) return; // 알림이 비활성화된 경우 종료

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'budget_exceeded_channel',
      'Budget Exceeded',
      channelDescription: 'Notifies when the budget is exceeded',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(
      1, // 고정된 ID로 알림 생성
      '예산 초과 알림',
      '총 지출이 설정한 예산을 초과했습니다!',
      notificationDetails,
    );
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
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(_selectedMonth),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _nextMonth,
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('예산 수정'),
                            content: TextField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(hintText: '예산 입력'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _saveBudget();
                                  Navigator.of(context).pop();
                                },
                                child: Text('저장'),
                              ),
                              TextButton(
                                onPressed: () {
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
                      '$totalBudget 원',
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
                Text('총 지출', style: TextStyle(fontSize: 16)),
                Text('${totalExpense.toString()} 원', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
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
                  widthFactor: (totalExpense / (totalBudget == 0 ? 1 : totalBudget)).clamp(0.0, 1.0),
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
                    ? '0%'
                    : '${(totalExpense / totalBudget * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
