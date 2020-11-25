import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  String userName;
  bool isOnline;
  bool isAvailable;


  User.fromJson (DocumentSnapshot ds) {
    uid = ds.documentID;
    Map jsonData = ds.exists ?? ds.data;

  }



}