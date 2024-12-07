import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import './refactor/actions/getdata_action.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

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
                  return ChangeNotifierProvider(
                      create: (_) => DataProvider(), child: MyHomePage(count: 0,));
                } else {
                  return LoginScreenPage();
                }
              } else {
                return LoginScreenPage();
              }
            }));
  }
}
