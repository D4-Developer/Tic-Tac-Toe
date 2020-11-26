import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import '../model/userModel.dart';

class UserProvider extends AuthProvider{
  User _authUser;
  Set<User> onlineUsers = Set();
  FirebaseUser _firebaseUser;
  BuildContext context;

  setFirebaseUser (firebaseUser) {
    if( _firebaseUser == null )
      _firebaseUser = firebaseUser;
    print('setter ' + _firebaseUser.uid);
    getOnlineUsers();
  }

  /// getter methods....
  ///
  // Set get onlineUsers => _onlineUsers;

  // UserProvider([this.context, this._firebaseUser]){
  //   if(_firebaseUser != null){
  //     print('firebaseuser != null');
  //     getOnlineUsers();
  //     notifyListeners();
  //   }
  // }



  /// can make return type Set if needed....
  getOnlineUsers() {

    Stream<QuerySnapshot> stream = Firestore.instance.collection('users')
        .where('isOnline', isEqualTo: true).snapshots().take(20);

    stream.listen((event) {
      onlineUsers = Set();
      event.documents.forEach((element) {
        if(element.documentID != _firebaseUser.uid)
          onlineUsers.add(User.fromJson(element.data));
      });

      print('ff');
      print(onlineUsers.length);
      notifyListeners();
    });
    // return onlineUsers;
  }
}