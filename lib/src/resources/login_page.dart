import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/fire_base_auth.dart';
import 'package:flutter_app/src/resources/register_page.dart';
import 'dialog/loading_dialog.dart';
import 'dialog/msg_dialog.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.auth}) : super(key: key);

  final BaseAuth auth;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Image.asset('room8-logo.png', width: 200),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 6),
                child: Text(
                  "Welcome back!",
                  style: TextStyle(fontSize: 22, color: Color(0xff333333)),
                ),
              ),
              Text(
                "Đăng nhập để tiếp tục sử dụng Room8",
                style: TextStyle(fontSize: 18, color: Color(0xff606470)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 70, 0, 20),
                child: TextFormField(
                  key: new Key('email'),
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Container(
                          width: 50, child: Image.asset("ic_mail.png")),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                  autocorrect: false,
                  validator: (val) =>
                      val.isEmpty ? 'Email không được rỗng' : null,
                  controller: _email,
                ),
              ),
              TextFormField(
                key: new Key('password'),
                style: TextStyle(fontSize: 18, color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    prefixIcon:
                        Container(width: 50, child: Image.asset("ic_lock.png")),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffCED0D2), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)))),
                autocorrect: false,
                validator: (val) =>
                    val.isEmpty ? 'Mật khẩu không được rỗng' : null,
                controller: _password,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: RaisedButton(
                    onPressed: _onLoginClick,
                    child: Text(
                      "Đăng nhập",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: Colors.black54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: RichText(
                  text: TextSpan(
                      text: "Người dùng mới? ",
                      style: TextStyle(color: Color(0xff606470), fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegisterPage(auth: widget.auth)));
                              },
                            text: "Đăng ký tài khoản mới",
                            style: TextStyle(
                                color: Color(0xff3277D8), fontSize: 16))
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onLoginClick() {
    LoadingDialog.showLoadingDialog(context, "Loading...");
    User loggedInUser = new User();
    var db = FirebaseDatabase.instance.reference().child("users");
    db
        .orderByChild("email")
        .equalTo(_email.text)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        loggedInUser.name = values["name"];
        loggedInUser.email = values["email"];
        loggedInUser.phone = values["phone"];
      });
    });
    widget.auth.signIn(_email.text, _password.text, () {
      LoadingDialog.hideLoadingDialog(context);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MenuDashboardPage(
                auth: widget.auth,
                currentUser: loggedInUser,
              )));
    }, (msg) {
      LoadingDialog.hideLoadingDialog(context);
      MsgDialog.showMsgDialog(context, "Đăng nhập", msg);
    });
  }
}
