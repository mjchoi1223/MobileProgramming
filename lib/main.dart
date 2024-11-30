import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:front/navigation/main_navigation.dart';
import 'package:front/screens/login/login_screen.dart';
import 'package:front/screens/transaction/transaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/transaction': (context) => TransactionScreen(),
      },
    );
  }
}

class AuthHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('인증 상태 오류: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          Future.microtask(() => Navigator.pushReplacementNamed(
                context,
                '/main',
                arguments: {'initialIndex': 0},
              ));
          return SizedBox.shrink();
        }

        Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
        return SizedBox.shrink();
      },
    );
  }
}
