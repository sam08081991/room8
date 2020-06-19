import 'package:flutter/material.dart';
import 'package:flutter_app/src/repository/fire_base_auth.dart';
import 'package:flutter_app/src/resources/login_page.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new LoginPage(auth: widget.auth);
  }
}
