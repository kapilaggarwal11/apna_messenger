import 'package:apna_messenger/helperFunctions/sharedPreferencesHelper.dart';
import 'package:apna_messenger/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen({this.chatWithUsername, this.name});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String myName, myProfilePicture, myUsername, myEmail;
  Stream messageStream;
  String chatRoomId, messageId = "";
  TextEditingController messageTextController = TextEditingController();

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myProfilePicture = await SharedPreferencesHelper().getUserProfilePicture();
    myUsername = await SharedPreferencesHelper().getUserName();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUsername);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.compareTo(b) == 1) {
      // print("__==");
      // print('j'.codeUnitAt(0));
      // print('k'.codeUnitAt(0));
      return "$b\_$a";
    } else {
      // print("__==");
      // print('j'.codeUnitAt(0));
      return "$a\_$b";
    }
  }

  addMessage(bool messageSent) {
    if (messageTextController.text != "") {
      String message = messageTextController.text;
      var messageTimeStamp = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUsername,
        "timeStamp": messageTimeStamp,
        "imgUrl": myProfilePicture,
      };

      //Message ID
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageTimeStamp": messageTimeStamp,
          "lastMessageSendBy": myUsername,
        };
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);
        if (messageSent) {
          messageTextController.text = "";
          messageId = "";
        }
      });
    }
  }

  Widget chatMessagesTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: sendByMe ? Colors.black26 : Color(0xFF1C6CB5),
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: sendByMe ? Colors.black : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(
                  bottom: 60,
                ),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessagesTile(
                    ds["message"],
                    myUsername == ds["sendBy"],
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        backgroundColor: Color(0xFF1C6CB5),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          addMessage(false);
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        controller: messageTextController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Icon(
                        Icons.send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Column(
// children: [
// Column(
// children: [
// chatMessages(),
// ],
// ),
// // Expanded(
// //   child: Container(
// //     child: chatMessages(),
// //   ),
// // ),
// Container(
// decoration: BoxDecoration(
// color: Colors.black12,
// ),
// padding: EdgeInsets.symmetric(
// horizontal: 20,
// vertical: 5,
// ),
// child: Row(
// children: [
// Expanded(
// child: TextField(
// onChanged: (value) {
// addMessage(false);
// },
// style: TextStyle(
// fontWeight: FontWeight.w500,
// ),
// controller: messageTextController,
// decoration: InputDecoration(
// border: InputBorder.none,
// hintText: 'Type a message...',
// hintStyle: TextStyle(
// fontStyle: FontStyle.italic,
// fontWeight: FontWeight.w500,
// ),
// ),
// ),
// ),
// GestureDetector(
// onTap: () {
// addMessage(true);
// },
// child: Icon(
// Icons.send,
// ),
// ),
// ],
// ),
// ),
// ],
// )
