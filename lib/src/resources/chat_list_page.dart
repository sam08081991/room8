import 'package:flutter/material.dart';
import 'package:flutter_app/src/fire_base/fire_base_auth.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/resources/chat_detail_page.dart';
import 'customTile.dart';
import 'home_page.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key, this.auth, this.currentUser}) : super(key: key);
  final User currentUser;
  final BaseAuth auth;

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        leading: Container(
          margin: EdgeInsets.only(left: 25),
          child: InkWell(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MenuDashboardPage(
                    auth: widget.auth,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: ChatListContainer(widget.currentUser, widget.auth),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  final User currentUser;
  final BaseAuth auth;

  ChatListContainer(this.currentUser, this.auth);

  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: 2,
        itemBuilder: (context, index) {
          return CustomTile(
            mini: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatDetailPage(
                    auth: widget.auth,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
            title: Text(
              "User Name",
              style: TextStyle(
                  color: Colors.black87, fontFamily: "Arial", fontSize: 19),
            ),
            subtitle: Text(
              "Message",
              style: TextStyle(
                color: UniversalVariables.greyColor,
                fontSize: 14,
              ),
            ),
            leading: Container(
              constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: Image.asset("default-avatar.png").image,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserCircle extends StatelessWidget {
  final String text;

  UserCircle(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: UniversalVariables.separatorColor,
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: UniversalVariables.lightBlueColor,
                fontSize: 13,
              ),
            ),
          ),
//          Align(
//            alignment: Alignment.bottomRight,
//            child: Container(
//              height: 12,
//              width: 12,
//              decoration: BoxDecoration(
//                  shape: BoxShape.circle,
//                  border: Border.all(
//                      color: UniversalVariables.blackColor, width: 2),
//                  color: UniversalVariables.onlineDotColor),
//            ),
//          )
        ],
      ),
    );
  }
}
