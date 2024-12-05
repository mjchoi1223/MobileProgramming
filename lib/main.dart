import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:front/navigation/main_navigation.dart';
import 'package:front/screens/login/login_screen.dart';
import 'package:front/screens/transaction/transaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/budget/budget_screen.dart';
import 'package:front/screens/statistics/statistics_screen.dart';
import 'package:provider/provider.dart';
import 'package:front/theme_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// 알림 초기화
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.request();

  if (status.isGranted) {
    print('Notification permission granted');
  } else {
    print('Notification permission denied');
  }
}


Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('splash'); // 앱 아이콘 필요
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showBudgetExceededNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'budget_exceeded_channel', // 채널 ID
    'Budget Exceeded', // 채널 이름
    channelDescription: 'Notifies when the budget is exceeded', // 채널 설명
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '예산 초과 알림',
    '총 지출이 예산을 초과했습니다!',
    notificationDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotifications();

  // Firebase 및 알림 초기화
  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  await initializeNotifications();
  print('Notifications initialized successfully');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // ThemeProvider로 테마 관리
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '가계부 앱',
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.white,
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black),
                bodySmall: TextStyle(color: Colors.black),
                labelLarge: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              scaffoldBackgroundColor: Colors.black,
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.grey,
                backgroundColor: Colors.grey[900],
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Colors.white),
                labelLarge: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              colorScheme: ColorScheme.dark().copyWith(
                surface: Colors.grey[850]!,
                background: Colors.black,
                onBackground: Colors.white,
                primary: Colors.green,
                onPrimary: Colors.white,
                secondary: Colors.purple,
                onSecondary: Colors.white,
              ),
            ),
            themeMode: themeProvider.themeMode, // 현재 테마 모드 반영
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => AuthHandler(),
              '/login': (context) => LoginScreen(),
              '/main': (context) {
                final args = ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {'initialIndex': 0};
                return MainNavigation(initialIndex: args['initialIndex']);
              },
              '/statistics': (context) {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) {
                  return LoginScreen();
                }
                return StatisticsScreen(userId: userId);
              },
              '/transaction': (context) {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  return TransactionScreen();
                } else {
                  return LoginScreen();
                }
              },
              '/budget': (context) => BudgetScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Checking authentication state...');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Authentication: Waiting for connection...');
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print('Authentication Error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('인증 상태 오류: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          print('User authenticated: ${snapshot.data}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/main',
              arguments: {'initialIndex': 0},
            );
          });
          return SizedBox.shrink();
        }

        print('User not authenticated. Redirecting to login screen...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return SizedBox.shrink();
      },
    );
  }
}
