import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/src/fire_base/fire_base_auth.dart';
import 'package:flutter_app/src/models/room.dart';
import 'package:flutter_app/src/resources/utils.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/models/user.dart';

import 'home_page.dart';

@immutable
class UpdateRoomInfo extends StatefulWidget {
  UpdateRoomInfo({Key key, this.currentUser, this.auth}) : super(key: key);
  final BaseAuth auth;
  final User currentUser;
  final String title = 'My Room';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final fireStoreInstance = Firestore.instance;
  final Room room = new Room();

  @override
  _UpdateRoomInfoState createState() => _UpdateRoomInfoState();
}

class _UpdateRoomInfoState extends State<UpdateRoomInfo> {
  List<Asset> files = new List<Asset>();
  List<String> statePhotoURLs = <String>[];
  String _error = 'No Error Dectected';
  List<int> numbers = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<String> areas = <String>[
    "nhỏ  10 mét vuông",
    "15 mét vuông",
    "20 mét vuông",
    "25 mét vuông",
    "hơn 25 mét vuông"
  ];
  int _numberOfSlots = 1;
  int _neededSlots = 1;
  String _selectedArea;
  TextEditingController _address = TextEditingController();
  TextEditingController _price = TextEditingController();
  bool _hasAttic = false;
  bool _isFreeEntrance = false;

  updateState() {
    widget.fireStoreInstance
        .collection("rooms")
        .where("owner_email", isEqualTo: widget.currentUser.email)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        setState(() {
          widget.room.ownerEmail = result.data["owner_email"];
          widget.room.photoUrls = List.from(result.data["photo_urls"]);
          widget.room.address = result.data["address"];
          widget.room.area = result.data["area"];
          widget.room.numberOfSlots = result.data["number_of_slots"];
          widget.room.neededSlots = result.data["needed_slots"];
          widget.room.hasAttic = result.data["has_attic"];
          widget.room.isFreeEntrance = result.data["is_free_entrance"];
          widget.room.price = result.data["price"];

          _neededSlots =
              widget.room.neededSlots != null ? widget.room.neededSlots : 0;
          _numberOfSlots =
              widget.room.numberOfSlots != null ? widget.room.numberOfSlots : 0;
          _selectedArea =
              widget.room.area != null ? widget.room.area : "nhỏ  10 mét vuông";
          _address.text =
              widget.room.address != null ? widget.room.address : "";
          _hasAttic =
              widget.room.hasAttic != null ? widget.room.hasAttic : false;
          _isFreeEntrance = widget.room.isFreeEntrance != null
              ? widget.room.isFreeEntrance
              : false;
          _price.text = widget.room.price != null ? widget.room.price : "0";
        });
      });
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#51555F",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      files = resultList;
      _error = error;
    });
  }

  void uploadImages() {
    if (files.length != 0) {
      for (var imageFile in files) {
        postImage(imageFile).then((downloadUrl) {
          statePhotoURLs.add(downloadUrl.toString());
          if (statePhotoURLs.length == files.length) {
            setState(() {
              statePhotoURLs.forEach((element) {
                if (widget.room.photoUrls == null) {
                  widget.room.photoUrls = new List<String>();
                }
                widget.room.photoUrls.add(element);
              });
              statePhotoURLs.clear();
              files.clear();
              updateRoomInfo();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MenuDashboardPage(
                    currentUser: widget.currentUser,
                    auth: widget.auth,
                  ),
                ),
              );
            });
          }
        }).catchError((err) {
          print(err);
        });
      }
    } else {
      statePhotoURLs.clear();
      files.clear();
      updateRoomInfo();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MenuDashboardPage(
            currentUser: widget.currentUser,
            auth: widget.auth,
          ),
        ),
      );
    }
  }

  List<DropdownMenuItem<String>> buildDropdownMenuStringItems(List areas) {
    List<DropdownMenuItem<String>> items = List();
    for (String area in areas) {
      items.add(
        DropdownMenuItem(
          value: area,
          child: Text(area),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> buildDropdownMenuNumberItems(List numbers) {
    List<DropdownMenuItem<int>> items = List();
    for (int number in numbers) {
      items.add(
        DropdownMenuItem(
          value: number,
          child: Text("${number}"),
        ),
      );
    }
    return items;
  }

  void toggleCheckboxHasAttic(bool value) {
    if (_hasAttic == false) {
      setState(() {
        _hasAttic = true;
        widget.room.hasAttic = true;
      });
    } else {
      setState(() {
        _hasAttic = false;
        widget.room.hasAttic = false;
      });
    }
  }

  void toggleCheckboxIsFreeEntrance(bool value) {
    if (_isFreeEntrance == false) {
      setState(() {
        _isFreeEntrance = true;
        widget.room.isFreeEntrance = true;
      });
    } else {
      setState(() {
        _isFreeEntrance = false;
        widget.room.isFreeEntrance = false;
      });
    }
  }

  void updateRoomInfo() {
    if (widget.currentUser.roomId == null) {
      widget.fireStoreInstance
          .collection('rooms')
          .document(widget.currentUser.id)
          .setData({
        'owner_email': widget.currentUser.email,
        'photo_urls': widget.room.photoUrls,
        'address': _address.text,
        'area': widget.room.area,
        'number_of_slots': _numberOfSlots,
        'needed_slots': _neededSlots,
        'has_attic': _hasAttic,
        'is_free_entrance': _isFreeEntrance,
        'price': _price.text,
      });
    } else {
      widget.fireStoreInstance
          .collection('rooms')
          .document(widget.currentUser.id)
          .updateData({
        'owner_email': widget.currentUser.email,
        'photo_urls': widget.room.photoUrls,
        'address': _address.text,
        'area': widget.room.area,
        'number_of_slots': _numberOfSlots,
        'needed_slots': _neededSlots,
        'has_attic': _hasAttic,
        'is_free_entrance': _isFreeEntrance,
        'price': _price.text,
      });
    }
    widget.fireStoreInstance
        .collection('users')
        .document(widget.currentUser.id)
        .updateData({'roomId': widget.currentUser.id});
  }

  Future<dynamic> postImage(Asset imageFile) async {
    StorageReference reference = FirebaseStorage.instance.ref();
    ByteData byteData = await imageFile.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    StorageUploadTask uploadTask = reference
        .child("userPhotos")
        .child(widget.currentUser.id)
        .child("roomPhotos")
        .child(imageFile.name)
        .putData(imageData);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  Widget buildGridView() {
    if (files.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Hình mới",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (BuildContext c, int index) {
                    Asset asset = files[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: new AssetThumb(
                          asset: asset,
                          width: 300,
                          height: 300,
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(height: 5),
            Text(
              "Hình hiện có",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Expanded(child: LayoutBuilder(builder: (_, constraint) {
              if (widget.room.photoUrls != null) {
                return ListView.builder(
                  padding: const EdgeInsets.only(right: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.room.photoUrls.length,
                  itemBuilder: (BuildContext c, int index) {
                    return _buildCurrentPhotoItem(constraint, index);
                  },
                );
              } else {
                return Card(child: SizedBox(height: 80));
              }
            })),
          ],
        ),
      );
    } else if (widget.room.photoUrls != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Hình hiện có",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: LayoutBuilder(builder: (_, constraint) {
                return ListView.builder(
                  padding: const EdgeInsets.only(right: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.room.photoUrls.length,
                  itemBuilder: (BuildContext c, int index) {
                    return _buildCurrentPhotoItem(constraint, index);
                  },
                );
              }),
            ),
            SizedBox(height: 100),
          ],
        ),
      );
    } else {
      return SizedBox(height: 50);
    }
  }

  Card _buildCurrentPhotoItem(BoxConstraints constraint, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
            image: NetworkImage(widget.room.photoUrls[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    updateState();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      key: widget.scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: loadAssets,
                      child: ThreeDContainer(
                        width: 130,
                        height: 50,
                        backgroundColor: Colors.black12,
                        backgroundDarkerColor: MultiPickerApp.background,
                        child: Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        SnackBar snackBar = SnackBar(
                            content: Text('Hệ thống đang cập nhật...'));
                        widget.scaffoldKey.currentState.showSnackBar(snackBar);
                        uploadImages();
                      },
                      child: ThreeDContainer(
                        width: 130,
                        height: 50,
                        backgroundColor: Colors.black12,
                        backgroundDarkerColor: MultiPickerApp.background,
                        child: Center(
                          child: Icon(
                            Icons.system_update_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: buildGridView(),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 50, 20, 0),
                  child: TextFormField(
                    controller: _address,
                    autocorrect: false,
                    validator: (val) =>
                        val.isEmpty ? 'Address can\'t be empty.' : null,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.edit_location,
                        color: Colors.black87,
                        size: 30,
                      ),
                      hintText: 'Địa chỉ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.zoom_out_map),
                      Text("Diện tích:", style: TextStyle(fontSize: 16)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: _selectedArea,
                          items: areas
                              .map<DropdownMenuItem<String>>((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (selectedArea) {
                            setState(() {
                              _selectedArea = selectedArea;
                              widget.room.area = selectedArea;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 20,
                        child: Image.asset("stair-icon.png"),
                      ),
                      Text("Có gác:", style: TextStyle(fontSize: 16)),
                      Checkbox(
                        value: _hasAttic,
                        onChanged: (value) {
                          toggleCheckboxHasAttic(value);
                        },
                        activeColor: Colors.black54,
                        checkColor: Colors.white,
                        tristate: false,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.people),
                      Text("Số người:", style: TextStyle(fontSize: 16)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: _numberOfSlots,
                          items: numbers.map<DropdownMenuItem<int>>((int item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text("${item}"),
                            );
                          }).toList(),
                          onChanged: (selectedItem) {
                            setState(() {
                              _numberOfSlots = selectedItem;
                              widget.room.numberOfSlots = selectedItem;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 55,
                      ),
                      Container(
                        width: 20,
                        child: Icon(Icons.timelapse),
                      ),
                      Text("Mở cửa tự do:", style: TextStyle(fontSize: 16)),
                      Checkbox(
                        value: _isFreeEntrance,
                        onChanged: (value) {
                          toggleCheckboxIsFreeEntrance(value);
                        },
                        activeColor: Colors.black54,
                        checkColor: Colors.white,
                        tristate: false,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Icon(Icons.group_add),
                      Text(
                        "Số chỗ trống:",
                        style: TextStyle(fontSize: 16),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: _neededSlots,
                          items: numbers.map<DropdownMenuItem<int>>((int item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text("${item}"),
                            );
                          }).toList(),
                          onChanged: (selectedItem) {
                            setState(() {
                              _neededSlots = selectedItem;
                              widget.room.neededSlots = selectedItem;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: _price,
                          autocorrect: false,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.monetization_on,
                              color: Colors.black87,
                              size: 30,
                            ),
                            hintText: 'Giá phòng',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ], // Only numbers can be entered
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
