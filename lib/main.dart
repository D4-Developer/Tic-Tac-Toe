import 'page/loginPage.dart';
import 'service/auth.dart';
import 'service/userService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

TextEditingController t = new TextEditingController();
var connection, userData;
void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

String x = Firestore.instance.collection('runningGame').document().documentID;

List<int> boardEmpty = [0, 0, 0, 0, 0, 0, 0, 0, 0];

class MainPageState extends State<MainPage> {
  @override
  void initState() {
//    initiateGame();
  }

  var gameStartedData = {
    'turn': 0,
    'player1': 'INF',
    'player2': 'RCB',
    'boardData': boardEmpty,
  };

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
        // ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, newAuth, preAuth) => preAuth
            ..setFirebaseUser(newAuth.firebaseUser)
        ),
      ],
      builder: (BuildContext context, child){
        return MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/playersPage': (context) => LoginPage()
          },
        );
      },
    );

    /*Scaffold(
        appBar: AppBar(
          title: Text("Tic Tac Toe"),
          actions: <Widget>[
            RaisedButton(
              color: Colors.white,
              child: Icon(Icons.filter_list),
              onPressed: () {},
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              ListTile(
//                title: Text("User name"),
                title: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  toolbarOptions: ToolbarOptions(paste: true),
                  maxLines: 1,
                  controller: t,
                  decoration: InputDecoration(
                    labelText: 'User name',
                    hintText: 'worrier',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: Icon(Icons.person, color: Colors.blue[900]),
                    //                          contentPadding: EdgeInsets.fromLTRB(2,25,2,5),
                  ),
                ),
              ),
              Center(
                  child: RaisedButton(
                child: Text("LOGIN"),
                onPressed: () async {
                  bool flag = await loginWithUserName();
                  if (flag) {
//                      await initiateGame(t.text);
                    userData = Firestore.instance
                        .collection('users')
                        .document(t.text)
                        .get();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PlayerList()));
                  }
                },
              )),
              googlePlayGames(),
            ],
          ),
        ),
      )
    );*/
  }

  googlePlayGames(){
    return Center(
      child: RaisedButton(
        shape: StadiumBorder(),
        onPressed: (){},
        child: Container(
          child: Text('Google play signin'),
        ),
      ),
    );
  }

  Future<bool> loginWithUserName() async {
    QuerySnapshot qs = await Firestore.instance
        .collection('users')
        .where('userName', isEqualTo: t.text)
        .getDocuments();

    if (qs.documents.length == 1) {
//      print('logined');
//      var data = {
//        'userName':'INF',
//        'isOnline': false,
//      };
//      await Firestore.instance.collection('users').document('INF').updateData(data);
//      data = {
//        'isAvailable': true,
//        'isOnline': true,
//        'userName':'RCB',
//      };
//      await Firestore.instance.collection('users').document('RCB').updateData(data);
      return true;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: 200,
              height: 150,
              child: Text("No user exists as ${t.text}"),
            );
          });
    }
    return false;
  }

  /// login with userName....

}

class PlayerList extends StatefulWidget {
  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  Stream<DocumentSnapshot> gettingRequest() {
    Stream<DocumentSnapshot> qs =
        Firestore.instance.collection('users').document(t.text).snapshots();
//    return qs;
    qs.listen((ab) {
      print(ab.data);
      if (ab.data['isRequestAccepted']) {
//        print("accepted");
        connection = ab.data['gameData'];
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => GameStarted())));
      }
    });
    if (qs.isEmpty == true) {
      print("Empty");
    } else {
      print('getting request');
    }
  }

  Future initiateGame(String requestedPlayer) async {
    connection = Firestore.instance.collection('runningGame').document().documentID;
    var data = {
      'gameData': connection,
      'isAvailable': false,
      'isRequestAccepted': true,
//      'turn': 1,
    };
    await Firestore.instance.collection('users').document(requestedPlayer)
        .updateData(data);
    data = {
      'turn': 0,
      'turnCount': 0,
      'winner': false,
      'gameData': connection,
      'isGameOver': false,
      'gameBoard': boardEmpty,
      'player1': requestedPlayer,
      'player2': userData['userName']
    };
    await Firestore.instance.collection('runningGame').document(connection).setData(data);
    print('initialized');
  }

  @override
  Widget build(BuildContext context) {
//    gettingRequest();
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Players"),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('isOnline', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    {
                      var online = {'isOnline': true};
                      Firestore.instance.collection('users')
                          .document(t.text)
                          .updateData(online);
//                    print(snapshot.data.documents.length);
                      List<DocumentSnapshot> documents = snapshot.data.documents;
                      if (snapshot.data.documents.length > 0) {
                        return ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (BuildContext context, index) {
                            if (documents.elementAt(index).data['userName'] != t.text) {
                              return Card(
                                color: Colors.blue[50],
                                child: ListTile(
                                  leading: Icon(Icons.people),
                                  title: Text("${documents.elementAt(index)['userName']}", textScaleFactor: 1),
                                  subtitle: Text("${userData['isRequestAccepted']}", textScaleFactor: 1),
                                  trailing: RaisedButton(
                                    onPressed: () async {
                                      if (documents.elementAt(index).data['isAvailable']) {
                                        var data = {
                                          'requestReceived': true,
                                          'requestedUser': userData['userName'],
//                                          'isAvailable': false
                                        };
                                        await Firestore.instance.collection('users')
                                            .document(documents.elementAt(index)['userName'])
                                            .updateData(data);
//                                        print("done");
                                        data = {'isRequestAccepted': false};
                                        await Firestore.instance.collection('users')
                                            .document(userData['userName']).updateData(data);
//                                        Stream <DocumentSnapshot> qs = gettingRequest();
                                        gettingRequest();
                                      }
                                    },
                                    child: Text("Request", textScaleFactor: 1),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        );
                      }
                      return Center(
                        child: Text(
                          "No Player is online right now.",
                          textScaleFactor: 1,
                        ),
                      );
                    }
                }
              },
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('users').document(t.text)
//                .where('requestReceived', isEqualTo: true) /// StreamBuilder<QuerySnapshot>
                  .snapshots(),
              builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    {
                      if (snapshot.hasData) {
                        userData = snapshot.data.data;
//                        print("stream : => $userData");
                        if (userData['requestReceived']) {
                          return Center(
                            child: Container(
                              color: Color.fromRGBO(155, 155, 155, 100),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Request received from ${userData['requestedUser']}",textScaleFactor: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      RaisedButton(
                                        onPressed: () => rDeclined(),
                                        child: Text("DECLINE"),
                                        color: Colors.redAccent,
                                      ),
                                      RaisedButton(
                                        onPressed:() => rAccepted(),
                                        child: Text("ACCEPT"),
                                        color: Colors.greenAccent,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          );
                        }
                        return Container();
                      }
                      return Container();
                    }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> rDeclined() async{
    var data = {
      'isDeclined': true,
      'isAvailble': true,
    };
    Firestore.instance.collection('users').document(userData['requestedUser']).updateData(data);
    userData['requestReceived'] = false;
    data = {
      'requestReceived': false,
      'isAvailable': true, /// may not need alltime....
      'requestedUser': null,
    };
    await Firestore.instance.collection('users').document(userData['userName']).updateData(data);
    print("Declined");
  }

  Future<void> rAccepted() async{
    await initiateGame(userData['requestedUser']);
    Navigator.push(context,MaterialPageRoute(builder: ((context) =>
        GameStarted())));
    var data = { 'isAvailable': false };
    Firestore.instance.collection('users').document(userData['userName']).updateData(data);
  }

}

class GameStarted extends StatefulWidget {
  @override
  _GameStartedState createState() => _GameStartedState();
}

class _GameStartedState extends State<GameStarted> {
  var gameData, player, width, height, turnCount = 0;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: height,
            width: width,
            color: Colors.cyan,
            child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('runningGame')
                    .document(connection).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      {
                        gameData = snapshot.data.data;
//                        print(gameData);
                        connection = gameData['gameData'];
                        var isFilled = gameData['gameBoard'];
                        turnCount = gameData['turnCount'];
                        print(isFilled);
                        if (gameData['player1'] == t.text)
                          player = 1;
                        else
                          player = 2;
                        print("winner = true");
                        int x;
                        x = winnerCheck();
                        print(" x = $x");
                        if(x > 0){
                          if(x==1){
                            gameData['isGameOver'] = true;
                            gameData['winnerName'] = gameData['player1'];
                          }
                          else{
                            gameData['isGameOver'] = true;
                            gameData['winnerName'] = gameData['player2'];
                          }
                        }
                        return Stack(
                          children: <Widget>[
                            ListView(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(20)),
                                Container(
                                    padding: EdgeInsets.all(20),
                                    child: (player == 1 && gameData['turn'] == 0) ||
                                        (player == 2 && gameData['turn'] == 1)
                                        ? Text("Your turn ")
                                        : Text("Other Player turn ")
                                  /// other player name ADD ?....
                                ),
                                Padding(padding: EdgeInsets.all(20)),
                                Container(
                                  height: height - height / 4,
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: 3,
                                    shrinkWrap: true,
                                    itemBuilder: (context, row) {
                                      return Container(
                                        padding: EdgeInsets.all(5),
                                        width: width - width / 10 * 4,
                                        height: height / 5,
                                        color: Colors.greenAccent,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 3,
                                          shrinkWrap: true,
                                          itemBuilder: (context, column) {
                                            int boxIndex = row * 3 + column;
                                            return Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: RaisedButton(
                                                color: Colors.blue[200],
                                                child: isFilled[boxIndex] > 0
                                                    ? (isFilled[boxIndex] == 1 ? Icon(Icons.clear)
                                                    : Text("O",style: TextStyle(fontSize: 20), textScaleFactor: 1,))
                                                    : null,
                                                onPressed: () async {
                                                  if (player == 1 && gameData['turn'] == 0 && isFilled[boxIndex] == 0) {
                                                    isFilled[boxIndex] = 1;
                                                    turnCount++;
                                                    var x,data;
                                                    data = {
                                                      'gameBoard': isFilled,
                                                      'turn': 1,
                                                      'turnCount': turnCount,
                                                    };
                                                    if(turnCount > 4){
                                                      x = winnerCheck();
                                                      if(x > 0){
                                                        gameData['isGameOver'] = true;
                                                        print(" x = $x");
                                                        if(x==1)
                                                          gameData['winnerName'] = gameData['player1'];
                                                        else
                                                          gameData['winnerName'] = gameData['player2'];
                                                        data = {
                                                          'gameBoard': isFilled,
                                                          'isGameOver': true,
                                                          'turn': -1,
                                                          'turnCount': turnCount,
                                                          'winner': gameData['winnerName']
                                                        };
                                                      }
                                                    }
//                                                print(turnCount);
                                                    await Firestore.instance.collection('runningGame')
                                                        .document(connection).updateData(data);
//                                                print("player 1 turned");
                                                  } else if (player == 2 && gameData['turn'] == 1 && isFilled[boxIndex] == 0) {
                                                    isFilled[boxIndex] = 2;
                                                    turnCount++;
                                                    var x,data;
                                                    data = {
                                                      'gameBoard': isFilled,
                                                      'turn': 0,
                                                      'turnCount': turnCount,
                                                    };
                                                    if(turnCount > 4){
                                                      x = winnerCheck();
                                                      if(x > 0){
                                                        gameData['isGameOver'] = true;
                                                        print(" x = $x");
                                                        if(x==1)
                                                          gameData['winnerName'] = gameData['player1'];
                                                        else
                                                          gameData['winnerName'] = gameData['player2'];
                                                        data = {
                                                          'gameBoard': isFilled,
                                                          'isGameOver': true,
                                                          'turn': -1,
                                                          'turnCount': turnCount,
                                                          'winner': gameData['winnerName']
                                                        };
                                                      }
                                                    }
//                                                print(turnCount);
                                                    await Firestore.instance
                                                        .collection('runningGame')
                                                        .document(connection)
                                                        .updateData(data);
//                                                print("player 2 turned");
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if(gameData['isGameOver'])
                              Center(
                                child: Container(
                                  color: Colors.pinkAccent[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Winner : ${gameData['winnerName']}"),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        );
                      }
                  }
                }),
          ),
        );
      })
    );
  }

  int winnerCheck(){
    int winner = 0;
    for(int i=0; i<7; i++){
      if(gameData['gameBoard'][i]>0){
        if(i%3 == 0) {
          if(gameData['gameBoard'][i]==gameData['gameBoard'][i+1] && gameData['gameBoard'][i]==gameData['gameBoard'][i+2]){
            if(gameData['gameBoard'][i] == 1)
              winner = 1;
            else
              winner = 2;
            break;
          }
        }
        if(i<3){
          if(gameData['gameBoard'][i]==gameData['gameBoard'][i+3] && gameData['gameBoard'][i]==gameData['gameBoard'][i+6]){
            if(gameData['gameBoard'][i] == 1)
              winner = 1;
            else
              winner = 2;
            break;
          }
        }
        if(i==0 || i==2){
          if(gameData['gameBoard'][0]==gameData['gameBoard'][4] && gameData['gameBoard'][0]==gameData['gameBoard'][8]){
            if(gameData['gameBoard'][i] == 1)
              winner = 1;
            else
              winner = 2;
            break;
          }
          if(gameData['gameBoard'][2]==gameData['gameBoard'][4] && gameData['gameBoard'][2]==gameData['gameBoard'][6]) {
            if(gameData['gameBoard'][i] == 1)
              winner = 1;
            else
              winner = 2;
            break;
          }
        }
      }
    }
    print("winner = $winner");
    return winner;
  }

  void winnerDialog(String winner) async{

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          Container(
            child: Column(
              children: [
                Text("Winner : $winner", textScaleFactor: 1),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Text("HOME"),
                      onPressed: () {
                        print("HOME Pressed");
//                        Navigator.pop(context);
                        Navigator.pop(context);

                      },
                    ),
                    RaisedButton(
                      child: Text("CONTINUE"),
                      onPressed: () async{
                        print("Continue");

                        await Firestore.instance.collection('runnningGame').document(connection).delete();
                        connection = Firestore.instance.collection('runningGame').document().documentID;
                        var data = {
                          'turn': 0,
                          'turnCount': 0,
                          'gameData': connection,
                          'gameBoard': boardEmpty,
                          'player1': userData['userName'],
                          'player2': gameData['secondPlayer']
                        };

                        await Firestore.instance
                            .collection('runningGame')
                            .document(connection)
                            .setData(data);
                      },
                    ),
                  ],
                )
              ]
            ),
          )
    );
  }
}
