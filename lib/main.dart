import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM の通知権限リクエスト
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  String? fcmToken = await messaging.getToken();
  print('FCM TOKEN: $fcmToken');
  initializeDateFormatting().then((_) => runApp(MyApp(
        fcmToken: fcmToken
      )));
}

class MyApp extends StatelessWidget {
  MyApp({required this.fcmToken});
  // This widget is the root of your application.
  String? fcmToken;

  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shift Manager',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 54, 146, 57)),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(
                    "this is user emailVerified [${snapshot.data!.emailVerified}]");
                if (snapshot.data!.emailVerified) {
                  final db = FirebaseFirestore.instance;
                  final auth = FirebaseAuth.instance;
                  final userId = auth.currentUser?.uid.toString();
                  db
                      .collection('Users')
                      .doc(userId)
                      .collection("MyInfo")
                      .doc("userInfo")
                      .update({"token": fcmToken});
                  return ChangeNotifierProvider(
                      create: (_) => DataProvider(),
                      child: MyHomePage(
                        count: 0,
                      ));
                } else {
                  return LoginScreenPage();
                }
              } else {
                return LoginScreenPage();
              }
            }));
  }
}
