import 'package:flutter/material.dart';

class AddFriendScreen extends StatelessWidget {
  final String userId;

  const AddFriendScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("친구 추가"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("친구 추가 화면 (구현 예정)"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}
