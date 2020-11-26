import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import '../model/userModel.dart';

class UserProvider extends AuthProvider{
  User _user;
  Set<User> onlineUsers = Set();
  FirebaseUser _firebaseUser;
  BuildContext context;

  /// getter methods....
  ///
  // Set get onlineUsers => _onlineUsers;

  // UserProvider(this.context){
  //   _firebaseUser = Provider.of<AuthProvider>(context, listen: false).firebaseUser;

  // }



  List getOnlineUsers() {

    Stream<QuerySnapshot> stream = Firestore.instance.collection('users')
        .where('isOnline', isEqualTo: true).snapshots().take(10);

    stream.listen((event) {
      onlineUsers = List.castFrom(event.documents.where((element) => false)).toList().toSet();
      // List.from(event.documents.where((element) => false)).toList();
      event.documents.where((element) {
        if(element.documentID != _firebaseUser.uid)
          return true;
      });
      event.documents.forEach((element) {
        onlineUsers.add(User.fromJson(element.data));
      });

      for(User u in onlineUsers){
        print(u.userName);
      }
      print('ff');
      print(onlineUsers.length);
      return onlineUsers.toList();
    });
  }



}