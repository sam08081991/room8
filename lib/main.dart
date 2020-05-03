import 'package:flutter/material.dart';
import 'package:flutter_app/src/app.dart';
import 'package:flutter_app/src/blocs/auth_bloc.dart';
import 'package:flutter_app/src/resources/login_page.dart';
import 'package:flutter_app/src/resources/home_page.dart';

void main() {
  runApp(MyApp(
      new AuthBloc(),
      MaterialApp(
        home: LoginPage(),
      )));
}
