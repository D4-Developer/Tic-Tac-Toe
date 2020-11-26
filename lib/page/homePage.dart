import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/model/userModel.dart';
import 'package:tic_tac_toe/service/auth.dart';
import 'package:tic_tac_toe/service/userService.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  // Set<User> onlineUsers = Set();
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   AuthProvider authProvider = Provider.of<AuthProvider>(context,listen: false);
    //   // initUserProvider();
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(_index);
    return Builder(
      builder:(BuildContext context) {
        return Scaffold(
        body: SafeArea(
          // key: _scaffoldKey,
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
              setState(() => _index = index);
            // print(index);
          },
        ),
      );
      }
    );
  }

  _playersStack() {
    // List<User> users = _userProvider.onlineUsers.toList();
    return Consumer<UserProvider>(
      builder: (context, state, child){
        // print(onlineUsers.length);
        return Container(
          child: AnimatedList(
            // itemCount: state.onlineUsers.length,
            initialItemCount: 3,
            itemBuilder: (BuildContext context, index, _){
              return ListTile(
                title: Text(state.onlineUsers.elementAt(index).userName),
              );
            },
          ),
        );
      },
      child: Center(
        child: CircularProgressIndicator(),
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
