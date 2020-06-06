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

  @override
  UpdateRoomInfoState createState() => UpdateRoomInfoState();
}

class UpdateRoomInfoState extends State<UpdateRoomInfo> {
  List<Asset> files = new List<Asset>();
  List<String> photoURLs = <String>[];
  String _error = 'No Error Dectected';
  Room room;

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
        photoURLs.add(downloadUrl.toString());
        if (photoURLs.length == files.length) {
          Firestore.instance
              .collection('images')
              .document(widget.currentUser.id)
              .setData({'urls': photoURLs}).then((_) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MenuDashboardPage(
                      currentUser: widget.currentUser,
                      auth: widget.auth,
                    )));
          });
        }
      }).catchError((err) {
        print(err);
      });
    }
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
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (BuildContext c, int index) {
          Asset asset = files[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
            ),
          );
        });
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
