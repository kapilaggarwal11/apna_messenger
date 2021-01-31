import 'package:apna_messenger/helperFunctions/sharedPreferencesHelper.dart';
import 'package:apna_messenger/screens/chatScreen.dart';
import 'package:apna_messenger/screens/signInScreen.dart';
import 'package:apna_messenger/services/auth.dart';
import 'package:apna_messenger/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearching = false;
  String myName, myProfilePicture, myUsername, myEmail;
  Stream usersStream, chatRoomStream;
  TextEditingController searchBarTextController = TextEditingController();

  onSearchButtonClick() async {
    setState(() {
      isSearching = true;
    });
    usersStream =
        await DatabaseMethods().getUserByUserName(searchBarTextController.text);
    setState(() {});
  }

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferencesHelper().getDisplayName();
    myProfilePicture = await SharedPreferencesHelper().getUserProfilePicture();
    myUsername = await SharedPreferencesHelper().getUserName();
    print("-=-=-===-=-=-=-=-=-=-=-==-=-=-=-");
    // print(myName);
    print(myUsername);
    myEmail = await SharedPreferencesHelper().getUserEmail();
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget searchedUserTile({String name, imgUrl, email, username}) {
    return GestureDetector(
      onTap: () {
        print("Check0");
        var chatRoomId = getChatRoomIdByUsernames(myUsername, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUsername, username]
        };

        print("Check1");
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    chatWithUsername: username,
                    name: name,
                  )),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imgUrl),
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Text(email),
            ],
          ),
        ],
      ),
    );
  }

  Widget searchedUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchedUserTile(
                    name: ds["name"],
                    imgUrl: ds["imgUrl"],
                    email: ds["email"],
                    username: ds["username"],
                  );
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                    lastMessage: ds["lastMessage"],
                    chatRoomId: ds.id,
                    myUserName: myUsername,
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getChatRooms() async {
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreferences();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apna Messenger'),
        backgroundColor: Color(0xFF1C6CB5),
        actions: [
          GestureDetector(
            onTap: () {
              AuthMethods().signOut().then((x) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ));
              });
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = false;
                              searchBarTextController.text = "";
                            });
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchBarTextController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "username",
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            onSearchButtonClick();
                          },
                          child: Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: 20,
              ),
              child: Expanded(
                child: isSearching ? searchedUsersList() : chatRoomsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUserName;
  ChatRoomListTile({this.lastMessage, this.chatRoomId, this.myUserName});
  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String imgUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUserName, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    imgUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    print("===---===");
    print(name);
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        chatWithUsername: username,
                        name: name,
                      )),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(imgUrl),
              ),
              SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Text(widget.lastMessage),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
