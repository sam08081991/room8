import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class BaseAuth {
  Future<FirebaseUser> currentUser();
  String signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError);
  void signUp(String email, String pass, String name, String phone, File photo,
      Function onSuccess, Function(String) onRegisterError);
  Future<void> signOut();
}

class FireAuth implements BaseAuth {
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;

  StreamController _nameController = new StreamController();
  StreamController _emailController = new StreamController();
  StreamController _passController = new StreamController();
  StreamController _phoneController = new StreamController();

  Stream get nameStream => _nameController.stream;
  Stream get emailStream => _emailController.stream;
  Stream get passStream => _passController.stream;
  Stream get phoneStream => _phoneController.stream;

  @override
  void signUp(String email, String pass, String name, String phone, File photo,
      Function onSuccess, Function(String) onRegisterError) {
    String userId;
    _fireBaseAuth
        .createUserWithEmailAndPassword(email: email, password: pass)
        .then((user) {
      userId = user.user.uid;
      _createUser(
          userId, name, phone, email, photo, onSuccess, onRegisterError);
    }).catchError((err) {
      print("err: " + err.toString());
      _onSignUpErr(err.code, onRegisterError);
    });
  }

  @override
  String signIn(String email, String pass, Function onSuccess,
      Function(String) onSignInError) {
    String userId;
    _fireBaseAuth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((user) {
      userId = user.user.uid;
      onSuccess();
    }).catchError((err) {
      print("err: " + err.toString());
      onSignInError("Cannot sign in, please try again");
    });
    return userId;
  }

  bool isValid(String name, String email, String pass, String phone) {
    if (name == null || name.length == 0) {
      _nameController.sink.addError("Nhập tên");
      return false;
    }
    _nameController.sink.add("");

    if (phone == null || phone.length == 0) {
      _phoneController.sink.addError("Nhập số điện thoại");
      return false;
    }
    _phoneController.sink.add("");

    if (email == null || email.length == 0) {
      _emailController.sink.addError("Nhập email");
      return false;
    }
    _emailController.sink.add("");

    if (pass == null || pass.length < 6) {
      _passController.sink.addError("Mật khẩu phải trên 5 ký tự");
      return false;
    }
    _passController.sink.add("");

    return true;
  }

  _createUser(String userId, String name, String phone, String email,
      File photo, Function onSuccess, Function(String) onRegisterError) {
    StorageUploadTask storageUploadTask;
    storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('userPhotos')
        .child(userId)
        .child('avatar')
        .child(userId)
        .putFile(photo);
    storageUploadTask.onComplete.then((ref) async {
      await ref.ref.getDownloadURL().then((url) async {
        await Firestore.instance.collection('users').document(userId).setData({
          'id': userId,
          'photourl': url,
          'name': name,
          'email': email,
          'phone': phone,
        });
      }).catchError((err) {
        print("err: " + err.toString());
        onRegisterError("SignUp fail by saving to storage, please try again");
      }).whenComplete(() {
        print("Save to storage completed");
      });
    });

    var user = Map<String, String>();
    user["name"] = name;
    user["email"] = email;
    user["phone"] = phone;

    var ref = FirebaseDatabase.instance.reference().child("users");
    ref.child(userId).set(user).then((vl) {
      onSuccess();
    }).catchError((err) {
      print("err: " + err.toString());
      onRegisterError("SignUp fail by saving to realtime DB, please try again");
    }).whenComplete(() {
      print("Save to real time database completed");
    });
  }

  Future<FirebaseUser> getFutureUser() async {
    return await _fireBaseAuth.currentUser();
  }

  FirebaseUser getUser(Future<FirebaseUser> user) {
    FirebaseUser result;
    user.then((user) {
      if (user != null) {
        result = user;
      }
    });
    return result;
  }

  void _onSignUpErr(String code, Function(String) onRegisterError) {
    print(code);
    switch (code) {
      case "ERROR_INVALID_EMAIL":
      case "ERROR_INVALID_CREDENTIAL":
        onRegisterError("Invalid email");
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        onRegisterError("Email has existed");
        break;
      case "ERROR_WEAK_PASSWORD":
        onRegisterError("The password is not strong enough");
        break;
      default:
        onRegisterError("SignUp fail, please try again");
        break;
    }
  }

  @override
  Future<FirebaseUser> currentUser() async {
    FirebaseUser user = await _fireBaseAuth.currentUser();
    return user != null ? user : null;
  }

  @override
  Future<void> signOut() async {
    return _fireBaseAuth.signOut();
  }

  void dispose() {
    _nameController.close();
    _emailController.close();
    _passController.close();
    _phoneController.close();
  }
}
