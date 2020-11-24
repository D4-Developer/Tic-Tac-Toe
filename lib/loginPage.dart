import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homePage.dart';
import 'loading.dart';
import 'service/auth.dart';

class LoginPage extends StatelessWidget {

  // TextEditingController _emailC = TextEditingController();
  // TextEditingController _passwordC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe-Online'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _emailPasswordForm(),
              // _loginButton()
              googleSignInButton(context)
            ],
          ),
        ),
      ),
    );
  }

/*
  _emailPasswordForm(){
    return Container(
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailC,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),

            TextFormField(
              controller: _passwordC,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),

          ],
        ),
      ),
    );
  }

  _loginButton(){
    return RaisedButton(
      child: Container(
        child: Text('Login'),
      ),
      onPressed: (){},
    );
  }
*/

  googleSignInButton(BuildContext context){
    return Center(
      child: Container(
        child: RaisedButton(
          shape: StadiumBorder(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward_ios),
              Container(
                child: Text('Google sign in'),
              )
            ],
          ),
          onPressed: (){
            loading(context);
            _googleSignIn(context);
          },
        ),
      ),
    );
  }
  
  _googleSignIn(BuildContext context) async{
    AuthProvider _authProvider = Provider.of<AuthProvider>(context, listen: false);

    if(await _authProvider.handleGoogleSignIn()
        && _authProvider.authStatus == AuthStatus.LoggedIn){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
    }

    else{
      /// showError message....
    }
  }

}
