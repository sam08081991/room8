import 'package:flutter/widgets.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User _user;
  AuthMethods _authMethods = AuthMethods();

  User get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
