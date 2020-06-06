import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app/src/resources/utils.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/models/user.dart';

@immutable
class UpdateRoomInfo extends StatefulWidget {
  UpdateRoomInfo({Key key, this.currentUser}) : super(key: key);
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

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
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
          String documentID = DateTime.now().millisecondsSinceEpoch.toString();
          Firestore.instance
              .collection('images')
              .document(documentID)
              .setData({'urls': photoURLs}).then((_) {
            setState(() {
              files = [];
              photoURLs = [];
            });
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
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(files.length, (index) {
        Asset asset = files[index];
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: ThreeDContainer(
            backgroundColor: MultiPickerApp.darker,
            backgroundDarkerColor: MultiPickerApp.darker,
            height: 50,
            width: 50,
            borderDarkerColor: MultiPickerApp.pauseButton,
            borderColor: MultiPickerApp.pauseButtonDarker,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  content: Text("No image selected",
                                      style: TextStyle(color: Colors.white)),
                                  actions: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: ThreeDContainer(
                                        width: 80,
                                        height: 30,
                                        backgroundColor:
                                            MultiPickerApp.navigateButton,
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
                          SnackBar snackbar = SnackBar(
                              content: Text('Please wait, we are uploading'));
                          widget.scaffoldKey.currentState
                              .showSnackBar(snackbar);
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
                          "Upload Images",
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
