import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/service/auth.dart';
import 'package:tic_tac_toe/service/userService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  UserProvider _userProvider;

  @override
  void initState() {

    // AuthProvider authProvider = Provider.of<AuthProvider>(context,listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false)
      .initUserData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_index);
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
        // type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            activeIcon: Icon(Icons.widgets_rounded),
            label: 'Players'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile'
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        onTap: (index){
          if (index != _index)
            setState(() {
              _index = index;
            });
          // print(index);
        },
      ),
    );
  }

  _playersStack() {
    return Container(
      child: Text('aa'),
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
