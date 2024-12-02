import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNearBudgetAlertEnabled = false;
  bool isOverBudgetAlertEnabled = false;
  double nearBudgetThreshold = 80; // 기본적으로 80% 설정
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (docSnapshot.exists) {
      final settings = docSnapshot.data();
      setState(() {
        isNearBudgetAlertEnabled = settings?['near_budget_alert'] ?? false;
        isOverBudgetAlertEnabled = settings?['over_budget_alert'] ?? true;
        nearBudgetThreshold = settings?['near_budget_threshold']?.toDouble() ?? 80.0;
      });
    }
  }

  Future<void> _saveSettings() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'near_budget_alert': isNearBudgetAlertEnabled,
      'over_budget_alert': isOverBudgetAlertEnabled,
      'near_budget_threshold': nearBudgetThreshold,
    }, SetOptions(merge: true));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // '/login' 경로로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("설정"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("알림 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text("예산 근접 알림"),
              subtitle: Text("지출액이 예산의 $nearBudgetThreshold% 이상이 되면 알림을 보냅니다."),
              value: isNearBudgetAlertEnabled,
              onChanged: (bool value) {
                setState(() {
                  isNearBudgetAlertEnabled = value;
                });
                _saveSettings();
              },
            ),
            if (isNearBudgetAlertEnabled)
              Slider(
                value: nearBudgetThreshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: "${nearBudgetThreshold.toInt()}%",
                onChanged: (double value) {
                  setState(() {
                    nearBudgetThreshold = value;
                  });
                  _saveSettings();
                },
              ),
            SwitchListTile(
              title: Text("예산 초과 알림"),
              subtitle: Text("지출액이 예산을 초과하면 알림을 보냅니다."),
              value: isOverBudgetAlertEnabled,
              onChanged: (bool value) {
                setState(() {
                  isOverBudgetAlertEnabled = value;
                });
                _saveSettings();
              },
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: _logout,
                child: Text("로그아웃", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
