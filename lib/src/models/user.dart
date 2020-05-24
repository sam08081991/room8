import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String email;
  String phone;
  String id;
  String photoUrl;

  User({this.id, this.email, this.name, this.phone, this.photoUrl});
}
