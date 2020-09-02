import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/services/firebaseDB.dart';
import 'package:test_live_app/pages/CartPage.dart';
import 'package:test_live_app/pages/InitialPage.dart';

import 'package:test_live_app/pages/LivePage.dart';

class ListLivePage extends StatefulWidget {
  @override
  _ListLivePageState createState() => _ListLivePageState();
}

class _ListLivePageState extends State<ListLivePage> {
  String username = 'tester1';

  @override
  void initState() {
    super.initState();
    // findUsername();
  }

  // Future<void> findUsername() async {
  //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   FirebaseUser firebaseUser = await firebaseAuth.currentUser();
  //   setState(() {
  //     username = firebaseUser.displayName;
  //     print(username);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.blue[600],
                Colors.blue[700],
                Colors.blue[800],
                Colors.blue[800],
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: signOutButton(),
        title: Column(
          children: <Widget>[
            appName(),
            showUsername(),
          ],
        ),
        actions: <Widget>[
          cartButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.fromLTRB(5, 5, 5, 33),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: StreamBuilder(
            stream: FireStoreClass.getCurrentLive(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data.documents.length == 0) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: availableHeight,
                  child: Center(
                    child: Text(
                      'No Current Streaming',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                );
              } else {
                // returnn doc.dat['role'] == 'admin ? widget 1 : widget2
                return Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 17,
                  ),
                  child: GridView.builder(
                    itemCount: snapshot.data.documents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height * 0.8),
                      crossAxisCount: 2,
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 2.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: liveContent(
                          title: '${snapshot.data.documents[index]["title"]}',
                          thumbnail:
                              '${snapshot.data.documents[index]["thumbnail"]}',
                          liveUser: 'Homepro1',
                          userProfile: 'assets/logo.png',
                          channelName:
                              '${snapshot.data.documents[index]["channelName"]}',
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget appName() {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'HomePro',
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
          TextSpan(
            text: ' Live',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget showUsername() {
    return Text(
      'Login by $username',
      style: TextStyle(
        color: Colors.white,
        fontSize: 8.0,
      ),
    );
  }

  Widget liveContent({thumbnail, liveUser, userProfile, channelName, title}) {
    return InkWell(
      onTap: () {
        print('Tap $liveUser');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LivePage(
              title: title,
              userProfile: userProfile,
              liveUser: liveUser,
              username: username,
              channelName: channelName,
              role: ClientRole.Audience,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(thumbnail),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // color: Colors.green,
                padding: EdgeInsets.all(5.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 6.0),
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.blue[800].withOpacity(0.6),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Live',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 20.0,
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 12.0,
                            ),
                            SizedBox(width: 1.0),
                            Center(
                              child: StreamBuilder(
                                stream: FireStoreClass.getViewer(
                                    liveUser, channelName),
                                builder: (BuildContext context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Text('0'),
                                    );
                                  } else {
                                    int viewers =
                                        snapshot.data.documents.length;
                                    return Text(
                                      viewers.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.0),
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 14.0,
                          backgroundImage: AssetImage(userProfile),
                          backgroundColor: Colors.blue[800],
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          liveUser,
                          style: TextStyle(color: Colors.white, fontSize: 12.0),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cartButton() {
    return IconButton(
      icon: Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
      tooltip: 'Cart',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(),
          ),
        );
      },
    );
  }

  Widget signOutButton() {
    return IconButton(
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
      tooltip: 'Logout',
      onPressed: () {
        signOutAlert();
      },
    );
  }

  void signOutAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to Logout?'),
          content: Text('This method will logged you out'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () {
                processSignOut();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> processSignOut() async {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext context) => InitialPage());
    Navigator.of(context)
        .pushAndRemoveUntil(materialPageRoute, (Route<dynamic> route) => false);
    // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    // await firebaseAuth.signOut().then((response) {
    //   MaterialPageRoute materialPageRoute =
    //       MaterialPageRoute(builder: (BuildContext context) => InitialPage());
    //   Navigator.of(context).pushAndRemoveUntil(
    //       materialPageRoute, (Route<dynamic> route) => false);
    // });
  }
}