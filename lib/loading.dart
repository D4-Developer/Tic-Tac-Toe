import 'package:flutter/material.dart';

void loading(BuildContext context,{String title = 'Loading...'}) {
  showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) =>
      Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          // backgroundColor: Colors.greenAccent,
        ),
      )
  );
}

void showSnackBar(BuildContext context, Widget snackBarData){
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: snackBarData,
    )
  );
}