import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('알림 설정'),
            onTap: () {
              // 알림 설정 클릭 시 동작
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('알림 설정 클릭')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('테마 변경'),
            onTap: () {
              // 테마 변경 클릭 시 동작
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('테마 변경 클릭')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('앱 정보'),
            onTap: () {
              // 앱 정보 클릭 시 동작
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('앱 정보 클릭')),
              );
            },
          ),
        ],
      ),
    );
  }
}
