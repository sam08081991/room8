import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.deepOrange[500],
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Center(
          child: Text('Rumate'),
        ),
      ),
      body: Center(
        child: Image(
          image: AssetImage('images/label-collection-with-vintage-style.jpg'),
        ),
      ),
    ));
  }
}
