import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:front/navigation/main_navigation.dart';
import 'package:front/screens/login/login_screen.dart';
import 'package:front/screens/transaction/transaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/budget/budget_screen.dart';
import 'package:front/screens/statistics/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가계부 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthHandler(),
        '/login': (context) => LoginScreen(),
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          final initialIndex = args['initialIndex'] ?? 0;
          return MainNavigation(initialIndex: initialIndex);
        },
        '/statistics': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) {
            return LoginScreen();
          }
          return StatisticsScreen(userId: userId);  // userId 전달
        },
        '/transaction': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId != null) {
            return TransactionScreen(userId: userId);
          } else {
            return LoginScreen();
          }
        },
        '/budget': (context) => BudgetScreen(),
      },
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
          Future.microtask(() => Navigator.pushReplacementNamed(
                context,
                '/main',
                arguments: {'initialIndex': 0},
              ));
          return SizedBox.shrink();
        }

        print('User not authenticated. Redirecting to login screen...');
        Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
        return SizedBox.shrink();
      },
    );
  }
}
