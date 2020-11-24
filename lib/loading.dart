import 'package:flutter/material.dart';

void loading(BuildContext context, {String info = 'loading...'}){
  showDialog(
    context: context,
    builder: (BuildContext context){
      return Container(
        child: Text(info),
      );
    }
  );
}