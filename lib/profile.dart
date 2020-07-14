import 'dart:io';
import 'contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class profile extends StatefulWidget {
  @override
  _profileState createState() => _profileState();
}

class _profileState extends State<profile> {
  File profilepic;
  String profileurl = " ";
  String name = " ";
  String bio = " ";
  String mail = " ";
  TextEditingController editname = new TextEditingController();
  TextEditingController editbio = new TextEditingController();
  @override
  Future<void> initState() {
    getdata();
    super.initState();
  }

  getdata() async {
    await FirebaseAuth.instance.currentUser().then((user) async {
      final userinfo = await Firestore.instance
          .collection("users")
          .where('uid', isEqualTo: user.uid)
          .getDocuments();
      setState(() {
        profileurl = userinfo.documents[0].data['photoURL'];
        name = userinfo.documents[0].data['nickname'];
        mail = userinfo.documents[0].data['mail'];
        bio = userinfo.documents[0].data['bio'];
      });

      print(profileurl);
    });
  }

  @override
  Future getimage() async {
    var newimage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilepic = newimage;
    });
  }

  Future uploadpic(BuildContext content) async {
    final StorageReference firebaseref =
        await FirebaseStorage.instance.ref().child('profilepictures');
    StorageUploadTask task = await firebaseref
        .child("pic" + DateTime.now().toString())
        .putFile(profilepic);
    StorageTaskSnapshot snapshot = await task.onComplete;
    var picurl = await snapshot.ref.getDownloadURL();
    updateprofilepic(picurl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("chatter_box"),
      ),
      body: Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
              Widget>[
        SizedBox(
          height: 30.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
              child: Container(
                  child: profilepic != null
                      ? CircleAvatar(
                          radius: 50, backgroundImage: FileImage(profilepic))
                      : CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(
                            "${profileurl}",
                          ),
                        )),
            ),
            Padding(
              padding: EdgeInsets.only(top: 70.0),
              child: IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: () {
                    getimage();
                  }),
            )
          ],
        ),
        SizedBox(height: 40),
        Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  child: Icon(Icons.person_pin_circle),
                )),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'nickname',
                  style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  name,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    Alert(
                        context: context,
                        title: "NickName",
                        content: TextField(
                          controller: editname,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle),
                            labelText: 'NickName',
                          ),
                        ),
                        buttons: [
                          DialogButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .currentUser()
                                  .then((user) {
                                Firestore.instance
                                    .collection('/users')
                                    .where('uid', isEqualTo: user.uid)
                                    .getDocuments()
                                    .then((docs) {
                                  Firestore.instance
                                      .document(
                                          '/users/${docs.documents[0].documentID}')
                                      .updateData({'nickname': editname.text});
                                });
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "save",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ]).show();
                  },
                  child: Icon(Icons.edit),
                ))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  child: Icon(Icons.perm_identity),
                )),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'bio',
                  style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  bio,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    Alert(
                        context: context,
                        title: "Bio",
                        content: TextField(
                          controller: editbio,
                          decoration: InputDecoration(
                            icon: Icon(Icons.account_circle),
                            labelText: 'Bio',
                          ),
                        ),
                        buttons: [
                          DialogButton(
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .currentUser()
                                  .then((user) {
                                Firestore.instance
                                    .collection('/users')
                                    .where('uid', isEqualTo: user.uid)
                                    .getDocuments()
                                    .then((docs) {
                                  Firestore.instance
                                      .document(
                                          '/users/${docs.documents[0].documentID}')
                                      .updateData({'Bio': editbio.text});
                                });
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "save",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ]).show();
                  },
                  child: Icon(Icons.edit),
                ))
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  child: Icon(Icons.email),
                )),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'mail',
                  style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                      fontWeight: FontWeight.w300),
                ),
                Text(
                  mail,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                )
              ],
            )),
            // Padding( padding: EdgeInsets.symmetric(horizontal:30),child: Container(child: Icon(Icons.edit),))
          ],
        ),
        SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.orange[100],
              elevation: 5.0,
              child: Text(
                'cancel',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            RaisedButton(
              onPressed: () {
                setState(() {
                  uploadpic(context);
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Contacts()));
              },
              color: Colors.orange[200],
              elevation: 5.0,
              child: Text(
                'Update',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            )
          ],
        )
      ])),
    );
  }
}

Future updateprofilepic(picurl) async {
  var userInfo = new UserUpdateInfo();
  userInfo.photoUrl = picurl;
  await FirebaseAuth.instance.currentUser().then((user) {
    Firestore.instance
        .collection('/users')
        .where('uid', isEqualTo: user.uid)
        .getDocuments()
        .then((docs) {
      Firestore.instance
          .document('/users/${docs.documents[0].documentID}')
          .updateData({'photoURL': picurl});
    });
  });
}
