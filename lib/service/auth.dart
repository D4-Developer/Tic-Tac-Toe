import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/userModel.dart';

enum AuthStatus {
  LoggedIn,
  NotLoggedIn,
  NotRegistered,
  NotDetermined
  // Authenticating,
  // Registering,
  // LoggedOut
}

class AuthProvider extends ChangeNotifier{

  User _user;
  FirebaseUser _firebaseUser;
  FirebaseAuth _firebaseAuth;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _authStatus = AuthStatus.NotLoggedIn;

  AuthStatus get authStatus => _authStatus;

  void set(AuthStatus status){
    _authStatus = status;
  }

  Future<bool> handleGoogleSignIn() async{

    try{
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if(googleUser == null){
        print('Failed Google Sign In');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );

      _firebaseUser = (await _firebaseAuth.signInWithCredential(credential)).user;

      if(await _initUserData(_firebaseUser)) {
        _authStatus = AuthStatus.LoggedIn;
        return true;
      }

    }catch(e){
      print(e.toString() + '@_handleGoogleSignIn');
    }

    _authStatus = AuthStatus.NotLoggedIn;
    return false;
  }

  _initUserData (FirebaseUser firebaseUser) async{
    try{
      DocumentSnapshot ds = await Firestore.instance.collection('users')
          .document(_firebaseUser.uid).get();

      Map<String, dynamic> data = ds.data;
      print(data);

      // return true;
    }catch(e){
      print(e.toString() + '@_initData');
    }

  }

}