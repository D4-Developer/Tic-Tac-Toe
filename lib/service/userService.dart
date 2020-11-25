import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import '../model/userModel.dart';

class UserProvider extends AuthProvider{
  User _user;
  List<User> _onlineUsers = List();
  FirebaseUser _firebaseUser;
  BuildContext context;

  UserProvider(this.context){
    _firebaseUser = Provider.of<AuthProvider>(context, listen: false).firebaseUser;
  }

  initUserData ({FirebaseUser firebaseUser}) async {
    try {
      print(_firebaseUser.uid);
      DocumentSnapshot ds = await Firestore.instance.collection('users')
          .document(_firebaseUser.uid).get();

      Map<String, dynamic> data = ds.data;
      print(data);

      /// getting started for online players list...
      OnlineUsers();
      // return true;
    } catch(e) {
      print(e.toString() + '@initUserData');
    }
    // return false;
  }

  OnlineUsers() {

    Stream<QuerySnapshot> stream = Firestore.instance.collection('users')
        .where('isOnline', isEqualTo: true).snapshots().take(10);

    stream.listen((event) {
      event.documents.forEach((element) {
        _onlineUsers.add(User.fromJson(element));
      });

      print('ff');
      print(_onlineUsers.length);
    });
  }



}