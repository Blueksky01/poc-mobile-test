import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mypoc1/views/login_view.dart';
import 'package:navigator/navigator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
               appBar: AppBar(
                title: Center(
                  child:Text('My POC App'))
                ),

        body: Center(
          child: Text('Hello World!')
          )
      ),
    );
  }
}
