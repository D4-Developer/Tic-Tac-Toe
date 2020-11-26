import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String userName;
  bool isOnline;
  bool isAvailable;


  User.fromJson (Map jsonData) {
    name = jsonData['name'];
    uid = jsonData['uid'];
    userName = jsonData['userName'];
    isOnline = jsonData['isOnline'];
    isAvailable = jsonData['isAvailable'];
  }

}