import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import 'package:provider/provider.dart';

/// 運営からのお知らせを表示するためのページ
/// 製作中

class Announce extends StatefulWidget {
  const Announce({super.key});

  @override
  State<Announce> createState() => _Announce();
}

class _Announce extends State<Announce> {
  var userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("お知らせ"),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (_) => DataProvider(),
                        child: MyHomePage(
                          count: 2,
                        ))));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey)),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          
                          
                          
                        ],
                      )
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ignore: non_constant_identifier_names
}
