import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/contact.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/auth_methods.dart';
import 'package:flutter_app/src/repository/chat_methods.dart';
import 'package:flutter_app/src/resources/chat_detail_page.dart';
import 'cache_image.dart';
import 'customTile.dart';
import 'last_message_container.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final User currentUser;
  final AuthMethods _authMethods = AuthMethods();
  final ChatMethods _chatMethods = ChatMethods();

  ContactView(this.contact, this.currentUser);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;

          return viewLayout(user, currentUser, context);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget viewLayout(User contact, User currentUser, BuildContext context) {
    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            receiver: contact,
            currentUser: currentUser,
          ),
        ),
      ),
      title: Text(
        (contact != null ? contact.name : null) != null ? contact.name : "..",
        style:
            TextStyle(color: Colors.black87, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: currentUser.id,
          receiverId: contact.id,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.photoUrl,
              radius: 80,
              isRound: true,
            ),
          ],
        ),
      ),
    );
  }
}
