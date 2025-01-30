import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1_shift_manager/refactor/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'refactor/login_items/login.dart';

// 初期画面
/*
機能：
アプリの起動、
ログイン状態検証、メールアドレスが認証済みか検証、
FCMトークンの取得・保存、
メインページへの遷移、ログイン画面への遷移
*/

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

  //FCMトークンの取得
  String? fcmToken = await messaging.getAPNSToken();
  initializeDateFormatting().then((_) => runApp(MyApp(fcmToken: fcmToken)));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key, required this.fcmToken});
  String? fcmToken;
  final db = FirebaseFirestore.instance;

  ///ログイン済みか、メールアドレスが認証済みかを検証
  ///FirestoreにFCMトークンを保存してFirebaseからの通知を可能にしている
  ///DataProviderで最初に必要な情報を取得する
  ///この情報はユーザーの情報やシフト情報で画面の描画等に使用する
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'shiftManager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF36AB13)),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //ログイン済みかの検証
              if (snapshot.hasData) {
                //メールアドレスが認証済みか検証
                if (snapshot.data!.emailVerified) {
                  //Firestoreのインスタンス
                  final db = FirebaseFirestore.instance;
                  //Firebase authのインスタンス
                  final auth = FirebaseAuth.instance;
                  //ユーザーID
                  final userId = auth.currentUser?.uid.toString();
                  if (fcmToken != null) {
                    //FirestoreにFCMトークンを保存
                    db
                        .collection('Users')
                        .doc(userId)
                        .collection("MyInfo")
                        .doc("userInfo")
                        .update({"token": fcmToken});
                  }

                  //Providerを作成、MyHomePageへ移行
                  return FutureBuilder(
                    future: DataProvider().fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ChangeNotifierProvider(
                          create: (_) => DataProvider(),
                          child: MyHomePage(count: 0),
                        );
                      } else {
                        return Builder(builder: (context) {
                          return Scaffold(
                            body: Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.white,
                                child: const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.green),
                                  backgroundColor:
                                      Color.fromARGB(255, 220, 237, 200),
                                  strokeWidth: 8.0,
                                ),
                              ),
                            ),
                          );
                        });
                      }
                    },
                  );
                } else {
                  //メールアドレスの認証が不完全な場合、ログインページにて認証のための手続きを行う
                  return LoginPage();
                }
              } else {
                //ログインが不完全な場合、ログインページへ遷移する
                return LoginPage();
              }
            }));
  }
}
