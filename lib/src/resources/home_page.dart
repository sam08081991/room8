import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/fire_base/fire_base_auth.dart';
import 'package:flutter_app/src/resources/login_page.dart';
import './page.dart';

class MenuDashboardPage extends StatefulWidget {
  MenuDashboardPage({this.auth});
  final BaseAuth auth;

  @override
  _MenuDashboardPageState createState() => _MenuDashboardPageState();
}

enum AuthStatus {
  signedIn,
}

class _MenuDashboardPageState extends State<MenuDashboardPage>
    with TickerProviderStateMixin {
  String currentProfilePic = null;
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 200);
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Stack(
        children: <Widget>[
          dashboard(context),
        ],
      ),
    );
  }

  Widget dashboard(BuildContext context) {
//    FirebaseUser user = this.getUser(widget.auth.currentUser());
//    print(user);
//    ref.getDownloadURL().then((loc) => setState(() => currentProfilePic = loc));
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("My Room8",
              style: TextStyle(fontSize: 24, color: Colors.white70)),
          centerTitle: true,
          backgroundColor: Colors.black54,
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  child: Icon(Icons.settings, color: Colors.white70),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountEmail: new Text("samsam@gmail.com"),
                accountName: new Text("Sam Nguyen"),
                currentAccountPicture: new GestureDetector(
                  child: new CircleAvatar(
                    backgroundImage:
                        new Image.asset('default-avatar.png').image,
                  ),
                  onTap: () => print("This is your current account."),
                ),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage("menu-top-background.jpg"),
                        fit: BoxFit.fill)),
              ),
              new ListTile(
                  title: new Text("Update room information"),
                  trailing: new Icon(Icons.home),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new Page("First Page")));
                  }),
              new ListTile(
                  title: new Text("Update profile"),
                  trailing: new Icon(Icons.info),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new Page("First Page")));
                  }),
              new ListTile(
                title: new Text("Cancel"),
                trailing: new Icon(Icons.input),
                onTap: () => Navigator.pop(context),
              ),
              new Divider(),
              new ListTile(
                title: new Text("Sign out"),
                trailing: new Icon(Icons.cancel),
                onTap: _onSignOutClicked,
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
          constraints: BoxConstraints.expand(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 150,
                    child: PageView(
                      controller: PageController(viewportFraction: 0.8),
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.redAccent,
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.blueAccent,
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.greenAccent,
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Transactions",
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Macbook"),
                          subtitle: Text("Apple"),
                          trailing: Text("-2900"),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 16,
                          color: Colors.black,
                        );
                      },
                      itemCount: 5)
                ],
              ),
            ),
          ),
        ));
  }

  void _onSignOutClicked() async {
    try {
      await widget.auth.signOut();
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LoginPage(auth: widget.auth)));
    } catch (e) {
      print(e);
    }
  }

  FirebaseUser getUser(Future<FirebaseUser> user) {
    FirebaseUser result;
    user.then((user) {
      if (user != null) {
        result = user;
      }
    });
    return result;
  }
}
