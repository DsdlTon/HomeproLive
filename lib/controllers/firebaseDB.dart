import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FireStoreClass {
  static FireStoreClass get instanace => FireStoreClass();

  static final Firestore _db = Firestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  static final chatCollection = 'chats';
  String url = '';
  List<String> allUserToken = [];

// ---Chat In Live-----------------------------------------------------------------

  static void saveChat(username, chatText, channelName) {
    _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Chats")
        .add({
      'username': username, //username is defined in foreground
      'msg': chatText, //chatText is TextController in Foreground
      'timeStamp': Timestamp.now(),
    });
  }

  static Stream<QuerySnapshot> getChat(channelName) {
    return _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

// ---Viewer in Live---------------------------------------------------------------------------

  static void saveViewer(username, liveAdmin, channelName) {
    _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Viewers")
        .document(username)
        .setData({
      'liveAdmin': liveAdmin,
    });

    print(
        '-------------- save username $username in $liveAdmin channal -------------------');
  }

  static Future<DocumentSnapshot> getClickToView(channelName) async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('CurrentLive')
        .document(channelName)
        .get();
    return snapshot;
  }

  static Stream<QuerySnapshot> getViewer(liveAdmin, channelName) {
    return _db
        .collection("CurrentLive")
        .document(channelName)
        .collection("Viewers")
        .snapshots();
  }

  static void deleteViewers({username, channelName}) async {
    await _db
        .collection("CurrentLive")
        .document(channelName)
        .collection('Viewers')
        .document(username)
        .delete();
    print('-------------- delete username $username ----------------');
  }

// ---All Live List----------------------------------------------------------------------------------------

  static Stream<QuerySnapshot> getCurrentLive() {
    var snapshot = _db
        .collection("CurrentLive")
        .where("onLive", isEqualTo: true)
        .snapshots();
    return snapshot;
  }

  static Stream<QuerySnapshot> getRecentlyLive() {
    var snapshot = _db
        .collection("CurrentLive")
        .where("onLive", isEqualTo: false)
        .snapshots();
    return snapshot;
  }

  // ---Chatroom List--------------------------------------------------------------------------------------

  static Stream<QuerySnapshot> getChatroom() {
    var snapshot = _db
        .collection("Chatroom")
        .orderBy("timeStamp", descending: true)
        .snapshots();
    return snapshot;
  }

  // static Stream<QuerySnapshot> getChatroomByName(username) {
  //   var snapshot = _db
  //       .collection("Chatroom")
  //       .where("chatWith", isEqualTo: username)
  //       .orderBy("timeStamp", descending: true)
  //       .snapshots();
  //   return snapshot;
  // }

  static Stream<QuerySnapshot> getChatroomData() {
    return _db.collection("Chatroom").snapshots();
  }

  static void setupChatroom(channelName, username, title) {
    _db.collection("Chatroom").document(channelName + username).setData({
      'channelName': channelName,
      'chatWith': username,
      'title': title,
      'isUserRead': true,
      'isAdminRead': false,
    });
    print(
        '------------------- Setup Chatroom channelName: $channelName$username success --------------------------');
  }

  static void deleteChatroom({channelName, username}) async {
    await _db.collection("Chatroom").getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
      print(
          '-------------------- delete Chatroom channelName: $channelName$username --------------------------------');
    });
  }

  // ---Chat In ChatRoom with Admin-----------------------------------------------------------------

  static void saveChatMessage({username, chatText, channelName, url}) {
    _db.collection("Chatroom").document(channelName + username).updateData(
      {
        'lastMsg': chatText,
        'timeStamp': Timestamp.now(),
        'isAdminRead': false,
      },
    ).then(
      (value) => _db
          .collection("Chatroom")
          .document(channelName + username)
          .collection("ChatMessage")
          .add(
        {
          'username': username, //username is defined in foreground
          'msg': chatText, //chatText is TextController in Foreground,
          'url': url,
          'timeStamp': Timestamp.now(),
          'role': "user",
        },
      ),
    );

    print(
        '---------------- save $chatText in $channelName+$username success --------------------------');
  }

  static Stream<QuerySnapshot> getChatMessage(channelName, username) {
    return _db
        .collection("Chatroom")
        .document(channelName + username)
        .collection("ChatMessage")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  static void setLastMsgWhenSentImage(channelName, username) {
    _db
        .collection("Chatroom")
        .document(channelName + username)
        .updateData({'lastMsg': '$username is sent a image'});
    print(
        '--------------- $channelName+$username is readed by User --------------------');
  }

  // ---Read Status----------------------------------------------------------------------------
  static void userReaded(channelName, username) {
    print('enter userReaded');
    _db
        .collection("Chatroom")
        .document(channelName + username)
        .updateData({'isUserRead': true});
    print(
        '--------------- $channelName+$username is readed by User --------------------');
  }
}
