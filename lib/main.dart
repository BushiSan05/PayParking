import 'package:flutter/material.dart';
import 'login.dart';
import 'delinquent.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'PayParking Login',
     debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: SignInPage(),
//        home:Delinquent(),
    );
  }
}