import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/contact.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/chat_methods.dart';
import 'package:flutter_app/src/repository/fire_base_auth.dart';
import 'contact_view.dart';
import 'home_page.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({Key key, this.auth, this.currentUser}) : super(key: key);
  final User currentUser;
  final BaseAuth auth;

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  void initState() {
    super.initState();
  }

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
      body: chatListContainer(widget.currentUser.id),
    );
  }

  Widget chatListContainer(String userId) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(
            userId: userId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;
              if (docList.isEmpty) {
                return Center(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 35, horizontal: 100),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Danh sách rỗng",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 30,
                              color: Colors.black38),
                        )
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);

                  return ContactView(contact, widget.currentUser);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
