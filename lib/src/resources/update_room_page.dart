import 'package:cloud_firestore/cloud_firestore.dart';
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
          widget.room.numberOfSlots = result.data["number_of_slot"];
          widget.room.neededSlots = result.data["needed_slots"];
          widget.room.hasAttic = result.data["has_attic"];
          widget.room.isFreeEntrance = result.data["is_free_entrance"];
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
  }

  void updateRoomInfo() {
    if (widget.currentUser.roomId == null) {
      widget.fireStoreInstance
          .collection('rooms')
          .document(widget.currentUser.id)
          .setData({
        'owner_email': widget.currentUser.email,
        'photo_urls': widget.room.photoUrls,
        'address': widget.room.address,
        'area': widget.room.area,
        'number_of_slots': widget.room.numberOfSlots,
        'needed_slots': widget.room.neededSlots,
        'has_attic': widget.room.hasAttic,
        'is_free_entrance': widget.room.isFreeEntrance,
      });
    } else {
      widget.fireStoreInstance
          .collection('rooms')
          .document(widget.currentUser.id)
          .updateData({
        'owner_email': widget.currentUser.email,
        'photo_urls': widget.room.photoUrls,
        'address': widget.room.address,
        'area': widget.room.area,
        'number_of_slots': widget.room.numberOfSlots,
        'needed_slots': widget.room.neededSlots,
        'has_attic': widget.room.hasAttic,
        'is_free_entrance': widget.room.isFreeEntrance,
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
              "New Picked Images",
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
              "Current Images",
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
              "Current Images",
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
                        backgroundColor: MultiPickerApp.navigateButton,
                        backgroundDarkerColor: MultiPickerApp.background,
                        child: Center(
                            child: Text(
                          "Pick images",
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (files.length == 0) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: Text("No image selected",
                                      style: TextStyle(color: Colors.black87)),
                                  actions: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: ThreeDContainer(
                                        width: 80,
                                        height: 30,
                                        backgroundColor: Colors.black87,
                                        backgroundDarkerColor:
                                            MultiPickerApp.background,
                                        child: Center(
                                            child: Text(
                                          "Ok",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    )
                                  ],
                                );
                              });
                        } else {
                          SnackBar snackBar = SnackBar(
                              content: Text('Please wait, we are uploading'));
                          widget.scaffoldKey.currentState
                              .showSnackBar(snackBar);
                          uploadImages();
                        }
                      },
                      child: ThreeDContainer(
                        width: 130,
                        height: 50,
                        backgroundColor: MultiPickerApp.navigateButton,
                        backgroundDarkerColor: MultiPickerApp.background,
                        child: Center(
                            child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        )),
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
                SizedBox(
                  height: 300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
