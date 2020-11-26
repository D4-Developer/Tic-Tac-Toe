import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/service/userService.dart';
import '../utilities/loading.dart';
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

class AuthProvider extends ChangeNotifier {

  User authUser;
  FirebaseUser _firebaseUser;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _authStatus = AuthStatus.NotLoggedIn;

  AuthStatus get authStatus => _authStatus;

  FirebaseUser get firebaseUser {
    print(_firebaseUser.email);
    return _firebaseUser;
  }

  // set authStatus (status) {
  //   _authStatus = status;
  // }

  Future<bool> handleGoogleSignIn(BuildContext context) async{

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null){
        print('Failed Google Sign In');

      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );

      AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
      _firebaseUser = authResult.user;
      
      if (authResult.additionalUserInfo.isNewUser)
        await _createUserInFireStore();
      else
        await initUserData();
        // return true;

      print('true');
      _setterFirebaseUser();
      _authStatus = AuthStatus.LoggedIn;
      return true;

    } catch (e) {
      print(e.toString() + '@_handleGoogleSignIn');
      /// .pop for loading showDialog
      // Navigator.pop(context);

      String msg = e.toString().contains('PlatformException(network_error,')
          ? 'Connect device to internet'
          : e.toString().substring(0,20);

      showSnackBar(context, Text(msg));
      return true;
    }

    _authStatus = AuthStatus.NotLoggedIn;
    return false;
  }

  _createUserInFireStore() async {
    print (_firebaseUser.displayName);
    // print (_firebaseUser.providerData);

    var newUserData = {
      'name': _firebaseUser.displayName,
      'userName': _createUserName(),
      'isOnline': false,
      'isAvailable': false,
      'uid': _firebaseUser.uid
    };


    await Firestore.instance.collection('users').document(_firebaseUser.uid)
        .setData(newUserData);
  }

  _createUserName () {
    String uid = _firebaseUser.uid.substring(0,5);
    return _firebaseUser.displayName.split(' ')[0] + uid;
  }

  Future initUserData () async {
    try {
      _firebaseUser = firebaseUser;
      print(_firebaseUser.uid);

      DocumentSnapshot ds = await Firestore.instance.collection('users')
          .document(_firebaseUser.uid).get();

      // Map<String, dynamic> data = ds.data;
      authUser = User.fromJson(ds.data);
      print(ds.data);
      // return true;
    } catch(e) {
      print(e.toString() + '@initUserData');
    }
    // return false;
  }

  _setterFirebaseUser() {
    // Provider.value(value: UserProvider).;
  }

}