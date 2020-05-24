import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/fire_base/fire_base_auth.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/resources/login_page.dart';
import './page.dart';

class MenuDashboardPage extends StatefulWidget {
  MenuDashboardPage({Key key, this.auth, this.currentUser}) : super(key: key);
  final BaseAuth auth;
  final User currentUser;
  final fireStoreInstance = Firestore.instance;

  @override
  _MenuDashboardPageState createState() => _MenuDashboardPageState();
}

class _MenuDashboardPageState extends State<MenuDashboardPage> {
  bool isCollapsed = true;
  double screenWidth, screenHeight;

  updateState() {
    widget.fireStoreInstance
        .collection("users")
        .where("email", isEqualTo: widget.currentUser.email)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          widget.currentUser.photoUrl = result.data["photourl"];
          widget.currentUser.id = result.data["id"];
        });
      });
    });
  }

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
    updateState();
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
                accountEmail: new Text(widget.currentUser.email),
                accountName: new Text(widget.currentUser.name),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: widget.currentUser.photoUrl != null
                      ? new NetworkImage(widget.currentUser.photoUrl)
                      : new Image.asset('default-avatar.png').image,
                ),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage("menu-top-background.jpg"),
                        fit: BoxFit.fill)),
              ),
              new ListTile(
                  title: new Text("Update room information",
                      style: TextStyle(fontSize: 15)),
                  trailing: new Icon(Icons.home),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new Page("First Page")));
                  }),
              new ListTile(
                  title: new Text("Update profile",
                      style: TextStyle(fontSize: 15)),
                  trailing: new Icon(Icons.info),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new Page("First Page")));
                  }),
              new ListTile(
                title: new Text("Dashboard", style: TextStyle(fontSize: 15)),
                trailing: new Icon(Icons.input),
                onTap: () => Navigator.pop(context),
              ),
              new ListTile(
                title: new Text("Sign out", style: TextStyle(fontSize: 15)),
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
}
