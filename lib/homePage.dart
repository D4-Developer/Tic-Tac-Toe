import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async{
            return false;
          },
          child: IndexedStack(
            index: _index,
            children: [
              _playersStack(),
              _profileStack()
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets),
            title: Text('Players')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile')
          ),
        ],
        onTap: (index){
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }

  _playersStack() {
    return SafeArea(
      child: Container(
        child: Text('players list'),
      ),
    );
  }

  _profileStack() {
    return SafeArea(
      child: Container(
        child: Text('profile tab'),
      ),
    );
  }
}
