import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/fire_base/fire_base_auth.dart';
import 'package:flutter_app/src/models/user.dart';
import 'home_page.dart';

class UpdateProfilePage extends StatefulWidget {
  UpdateProfilePage({Key key, this.auth, this.currentUser}) : super(key: key);
  final User currentUser;
  final String title = "My Profile";
  final FireAuth auth;
  final fireStoreInstance = Firestore.instance;
  final firebaseDatabase = FirebaseDatabase.instance;

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  void updateState() {
    setState(() {
      _nameController.text = widget.currentUser.name;
      _phoneController.text = widget.currentUser.phone;
    });
  }

  @override
  void initState() {
    updateState();
    super.initState();
  }

  @override
  void dispose() {
    widget.auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: size.width * 0.3,
                backgroundColor: Colors.transparent,
                backgroundImage: widget.currentUser.photoUrl != null
                    ? new NetworkImage(widget.currentUser.photoUrl)
                    : new Image.asset('default-avatar.png').image,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon: Container(
                          width: 50, child: Image.asset("ic_user.png")),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                ),
              ),
              TextField(
                controller: _phoneController,
                style: TextStyle(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Container(
                        width: 50, child: Image.asset("ic_phone.png")),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffCED0D2), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6)))),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: 100,
                  height: 52,
                  child: RaisedButton(
                    onPressed: updateProfile,
                    child: Icon(
                      Icons.system_update_alt,
                      color: Colors.white,
                    ),
                    color: Colors.black54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateProfile() {
    widget.firebaseDatabase
        .reference()
        .child('users')
        .child(widget.currentUser.id)
        .update({'name': _nameController.text, 'phone': _phoneController.text});
    widget.fireStoreInstance
        .collection('users')
        .document(widget.currentUser.id)
        .updateData(
            {'name': _nameController.text, 'phone': _phoneController.text});
    widget.currentUser.name = _nameController.text;
    widget.currentUser.phone = _phoneController.text;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuDashboardPage(
          currentUser: widget.currentUser,
          auth: widget.auth,
        ),
      ),
    );
  }
}
