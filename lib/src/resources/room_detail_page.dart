import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/room.dart';
import 'package:flutter_app/src/models/user.dart';
import 'package:flutter_app/src/repository/fire_base_auth.dart';
import 'package:flutter_app/src/resources/chat_detail_page.dart';
import 'package:flutter_app/src/resources/home_page.dart';

class RoomDetailPage extends StatefulWidget {
  RoomDetailPage({Key key, this.auth, this.room, this.currentUser})
      : super(key: key);
  final Room room;
  final User currentUser;
  final FireAuth auth;
  final fireStoreInstance = Firestore.instance;

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage>
    with TickerProviderStateMixin {
  AnimationController fadeController;
  AnimationController scaleController;
  Animation fadeAnimation;
  Animation scaleAnimation;
  double sheetTop = 400;
  double minSheetTop = 30;
  Animation<double> animation;
  AnimationController controller;
  bool isExpanded = false;
  double sheetItemHeight;
  Map mapVal;
  User receiver = new User();

  @override
  void initState() {
    super.initState();

    widget.fireStoreInstance
        .collection("users")
        .where("email", isEqualTo: widget.room.ownerEmail)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          receiver.id = result.data["id"];
          receiver.name = result.data["name"];
          receiver.email = result.data["email"];
          receiver.phone = result.data["phone"];
          receiver.photoUrl = result.data["photourl"];
          receiver.roomId = result.data["roomId"];
        });
      });
    });

    fadeController =
        AnimationController(duration: Duration(milliseconds: 180), vsync: this);

    scaleController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);

    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(fadeController);
    scaleAnimation = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ));
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: sheetTop, end: minSheetTop)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ))
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 25),
            child: InkWell(
              child: Icon(Icons.chat),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      receiver: receiver,
                      currentUser: widget.currentUser,
                      auth: widget.auth,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Stack(
      children: <Widget>[
        roomDetailsAnimation(context),
        customBottomSheet(context),
      ],
    );
  }

  forward() {
    scaleController.forward();
    fadeController.forward();
  }

  reverse() {
    scaleController.reverse();
    fadeController.reverse();
  }

  Widget roomDetailsAnimation(BuildContext context) {
    return StreamBuilder<Object>(
        initialData: StateProvider().isAnimating,
        stream: stateBloc.animationStatus,
        builder: (context, snapshot) {
          snapshot.data ? forward() : reverse();

          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: roomDetails(context),
            ),
          );
        });
  }

  Widget roomDetails(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 30),
          child: _carTitle(),
        ),
        Container(
          width: double.infinity,
          child: roomCarousel(context),
        )
      ],
    ));
  }

  _carTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white, fontSize: 30),
            children: [
              TextSpan(text: receiver.name),
              WidgetSpan(
                child: Container(
                  height: 5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        RichText(
          text: TextSpan(style: TextStyle(fontSize: 16), children: [
            TextSpan(
                text: widget.room.price,
                style: TextStyle(color: Colors.grey[20])),
            TextSpan(
              text: " VND / tháng",
              style: TextStyle(color: Colors.grey),
            )
          ]),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  int _current = 0;
  Widget roomCarousel(BuildContext context) {
    final List<String> imgList = widget.room.photoUrls;
    List<T> _map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i));
      }
      return result;
    }

    List<Widget> child = _map<Widget>(imgList, (index) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imgList[index]),
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }).toList();

    return Container(
      child: Column(
        children: <Widget>[
          CarouselSlider(
            height: 300,
            viewportFraction: 1.0,
            items: child,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(left: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: _map<Widget>(imgList, (index) {
                return Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                      color: _current == index
                          ? Colors.grey[100]
                          : Colors.grey[600]),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  forwardAnimation() {
    controller.forward();
    stateBloc.toggleAnimation();
  }

  reverseAnimation() {
    controller.reverse();
    stateBloc.toggleAnimation();
  }

  Widget customBottomSheet(BuildContext context) {
    return Positioned(
      top: animation.value,
      left: 0,
      child: GestureDetector(
        onTap: () {
          controller.isCompleted ? reverseAnimation() : forwardAnimation();
        },
        onVerticalDragEnd: (DragEndDetails dragEndDetails) {
          //upward drag
          if (dragEndDetails.primaryVelocity < 0.0) {
            forwardAnimation();
            controller.forward();
          } else if (dragEndDetails.primaryVelocity > 0.0) {
            //downward drag
            reverseAnimation();
          } else {
            return;
          }
        },
        child: sheetContainer(context),
      ),
    );
  }

  Widget sheetContainer(BuildContext context) {
    double sheetItemHeight = 120;
    return Container(
      padding: EdgeInsets.only(top: 25),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          color: Color(0xfff1f1f1)),
      child: Column(
        children: <Widget>[
          drawerHandle(),
          Expanded(
            flex: 1,
            child: ListView(
              children: <Widget>[
                addressDetails(sheetItemHeight),
                specifications(sheetItemHeight),
                features(sheetItemHeight),
                SizedBox(height: 220),
              ],
            ),
          )
        ],
      ),
    );
  }

  drawerHandle() {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      height: 3,
      width: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Color(0xffd9dbdb)),
    );
  }

  specifications(double sheetItemHeight) {
    double iconSize = 30;
    List<Map<Icon, Map<String, String>>> specifications = [
      {
        Icon(Icons.zoom_out_map, size: iconSize): {
          "Diện tích": widget.room.area
        }
      },
      {
        Icon(Icons.people, size: iconSize): {
          "Số người": "${widget.room.numberOfSlots}"
        }
      },
      {
        Icon(Icons.group_add, size: iconSize): {
          "Số chỗ\n trống ": "${widget.room.neededSlots}"
        }
      },
    ];
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15),
            height: sheetItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specifications.length,
              itemBuilder: (context, index) {
                return ListItem(
                  sheetItemHeight: sheetItemHeight,
                  mapVal: specifications[index],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  features(double sheetItemHeight) {
    double iconSize = 30;
    List<Map<Icon, Map<String, String>>> specifications = [
      {
        Icon(Icons.monetization_on, size: iconSize): {
          "Giá phòng": widget.room.price != null ? widget.room.price : "N/A"
        }
      },
      {
        Icon(Icons.show_chart, size: iconSize): {
          "Có gác": widget.room.hasAttic == true ? "Có" : "Không"
        }
      },
      {
        Icon(Icons.timelapse, size: iconSize): {
          "Mở cửa\n tự do": widget.room.isFreeEntrance == true ? "Có" : "Không"
        }
      },
    ];
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15),
            height: sheetItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specifications.length,
              itemBuilder: (context, index) {
                return ListItem(
                  sheetItemHeight: sheetItemHeight,
                  mapVal: specifications[index],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  addressDetails(double sheetItemHeight) {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white, fontSize: 38),
              children: [
                WidgetSpan(child: Icon(Icons.location_on)),
                TextSpan(
                  text: " " + widget.room.address,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final double sheetItemHeight;
  final Map mapVal;

  ListItem({this.sheetItemHeight, this.mapVal});

  @override
  Widget build(BuildContext context) {
    var innerMap;
    bool isMap;

    if (mapVal.values.elementAt(0) is Map) {
      innerMap = mapVal.values.elementAt(0);
      isMap = true;
    } else {
      innerMap = mapVal;
      isMap = false;
    }

    return Container(
      margin: EdgeInsets.only(right: 20),
      width: sheetItemHeight,
      height: sheetItemHeight,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          mapVal.keys.elementAt(0),
          isMap
              ? Text(innerMap.keys.elementAt(0),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, letterSpacing: 1.2, fontSize: 11))
              : Container(),
          Text(
            innerMap.values.elementAt(0),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}

class StateProvider {
  bool isAnimating = true;
  void toggleAnimationValue() => isAnimating = !isAnimating;
}

class StateBloc {
  StreamController animationController = StreamController.broadcast();
  final StateProvider provider = StateProvider();

  Stream get animationStatus => animationController.stream;

  void toggleAnimation() {
    provider.toggleAnimationValue();
    animationController.sink.add(provider.isAnimating);
  }

  void dispose() {
    animationController.close();
  }
}

final stateBloc = StateBloc();
