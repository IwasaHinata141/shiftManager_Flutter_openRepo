import 'dart:convert';
import 'package:http/http.dart' as http;


Future signUpAction(fullname, userId) async {
    return http.post(
      Uri.parse('https://make-directory-gpp774oc5q-an.a.run.app'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'fullname':fullname
      }),
    );
  }