import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/room.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/fire_base_auth.dart';
import 'package:flutter_app/src/resources/chat_list_page.dart';
import 'package:flutter_app/src/resources/login_page.dart';
import 'package:flutter_app/src/resources/room_detail_page.dart';
import 'package:flutter_app/src/resources/update_profile_page.dart';
import 'package:flutter_app/src/resources/update_room_page.dart';

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
  List<Room> _allRooms = new List<Room>();
  List<int> numbers = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<String> areas = <String>[
    "nhỏ  10 mét vuông",
    "15 mét vuông",
    "20 mét vuông",
    "25 mét vuông",
    "hơn 25 mét vuông"
  ];
  TextEditingController _searchController = TextEditingController();
  String query = "";

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
          widget.currentUser.roomId = result.data["roomId"];
        });
      });
    });
    _getData();
  }

  Future<void> _getData() async {
    widget.fireStoreInstance.collection("rooms").getDocuments().then((value) {
      List<Room> rooms = new List();

      value.documents.forEach((result) {
        Room room = new Room();

        room.ownerEmail = result.data["owner_email"];
        room.photoUrls = List.from(result.data["photo_urls"]);
        room.address = result.data["address"];
        room.area = result.data["area"];
        room.numberOfSlots = result.data["number_of_slots"];
        room.neededSlots = result.data["needed_slots"];
        room.hasAttic = result.data["has_attic"];
        room.isFreeEntrance = result.data["is_free_entrance"];
        room.price = result.data["price"];

        if (room.neededSlots != 0) {
          rooms.add(room);
        }
      });

      setState(() {
        _allRooms = rooms;
      });
    });
  }

  @override
  void initState() {
    updateState();
    super.initState();
  }

  @override
  void dispose() {
    _allRooms.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Stack(
        children: <Widget>[
          dashboard(context),
        ],
      ),
    );
  }

  Widget dashboard(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new PreferredSize(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  query = val;
                });
              },
              cursorColor: Colors.black87,
              autofocus: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _searchController.clear());
                  },
                ),
                border: InputBorder.none,
                hintText: "Tìm kiếm",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0x88ffffff),
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black54,
        actions: <Widget>[
          Row(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 13, 0),
                child: InkWell(
                  child: Icon(Icons.chat, color: Colors.white70),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatListPage(
                          auth: widget.auth,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                ),
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
                title: new Text("Cập nhật thông tin phòng",
                    style: TextStyle(fontSize: 15)),
                trailing: new Icon(Icons.hotel),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new UpdateRoomInfo(
                        currentUser: widget.currentUser,
                        auth: widget.auth,
                      ),
                    ),
                  );
                }),
            new ListTile(
                title:
                    new Text("Cập nhật hồ sơ", style: TextStyle(fontSize: 15)),
                trailing: new Icon(Icons.info),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new UpdateProfilePage(
                        currentUser: widget.currentUser,
                        auth: widget.auth,
                      ),
                    ),
                  );
                }),
            new ListTile(
              title: new Text("Đăng xuất", style: TextStyle(fontSize: 15)),
              trailing: new Icon(Icons.input),
              onTap: _onSignOutClicked,
            ),
          ],
        ),
      ),
      body: buildSuggestions(query, size),
    );
  }

  buildSuggestions(String query, Size size) {
    final List<Room> suggestionList = query.isEmpty
        ? _allRooms
        : _allRooms.where((Room room) {
            String _query = query.toLowerCase();
            String _getPrice =
                room.price != null ? room.price.toLowerCase() : "";
            String _getAddress = room.address.toLowerCase();
            return (_getAddress.contains(_query) || _getPrice.contains(_query));
          }).toList();

    return CustomScrollView(
      slivers: <Widget>[
        RefreshIndicator(
          child: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < suggestionList.length) {
                  return _cardBuilder(size, suggestionList[index]);
                } else {
                  return SizedBox(
                    height: 10,
                  );
                }
              },
              childCount: suggestionList.length,
            ),
          ),
          onRefresh: _getData,
        ),
      ],
    );
  }

  Widget _cardBuilder(Size size, Room item) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 10),
        height: 270,
        width: size.width,
        child: Card(
          margin: EdgeInsets.all(0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RoomDetailPage(
                        auth: widget.auth,
                        currentUser: widget.currentUser,
                        room: item,
                      )));
            },
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 180,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(item.photoUrls[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        width: size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      item.address.length > 35
                                          ? item.address.substring(0, 34) +
                                              "..."
                                          : item.address,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.monetization_on,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      item.price != null
                                          ? "  VND ${item.price}"
                                          : "  Chưa Cập Nhật",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "/tháng",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.group_add,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      "  ${item.neededSlots}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.timelapse,
                                      size: 20,
                                      color: item.isFreeEntrance == true
                                          ? Colors.black87
                                          : Colors.white12,
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 20,
                                      child: item.hasAttic == true
                                          ? Image.asset("stair-icon.png")
                                          : SizedBox(
                                              width: 1,
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 15,
                  bottom: 60,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black,
                          Colors.black54,
                          Colors.black38,
                        ],
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30.0),
                      onTap: () {},
                      child: Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignOutClicked() async {
    try {
      FireAuth auth = new FireAuth();
      await auth.signOut();
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LoginPage(auth: widget.auth)));
    } catch (e) {
      print(e);
    }
  }
}
