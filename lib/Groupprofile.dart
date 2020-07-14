import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Chat.dart';

String email;
FirebaseUser loggedinuser;
String photourl = '';
bool edit = false;
bool photoedit = false;
bool photo = false;
String groupdesc = '';
File picture;
String profileurl = " ";

class Groupprofile extends StatefulWidget {
  @override
  Groupprofile({this.groupid, this.name, this.pic});
  final String groupid;
  final String name;
  final String pic;

  _GroupprofileState createState() => _GroupprofileState();
}

class _GroupprofileState extends State<Groupprofile> {
  File profilepic;
  String grpurl;
  @override
  void initState() {
    super.initState();
    getgroupdesc();
    grpurl = widget.pic;
  }

  void getgroupdesc() async {
    final docs = await Firestore.instance
        .collection('Groups')
        .document(widget.groupid)
        .collection('description')
        .getDocuments();

    setState(() {
      for (var doc in docs.documents) {
        groupdesc = doc.data['description'];
        print(groupdesc);
      }
    });
  }

  void getgroupimage() async {
    final docs = await Firestore.instance
        .collection('Groups')
        .document(widget.groupid)
        .collection('about')
        .getDocuments();

    setState(() {
      for (var doc in docs.documents) {
        grpurl = doc.data['profileurl'];
      }
    });
  }

//  Future getimage() async{
//    var newimage=await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      profilepic=newimage;
//    });
//  }
  Future uploadpic(BuildContext content) async {
    final StorageReference firebaseref =
        await FirebaseStorage.instance.ref().child('grouppictures');
    StorageUploadTask task = await firebaseref
        .child("pic" + DateTime.now().toString())
        .putFile(picture);
    StorageTaskSnapshot snapshot = await task.onComplete;
    var picurl = await snapshot.ref.getDownloadURL();
    updateprofilepic(picurl, widget.groupid);
  }

  Future updateprofilepic(picurl, groupid) async {
    final docs = await Firestore.instance
        .collection('Groups')
        .document(groupid)
        .collection('about')
        .getDocuments();
    await Firestore.instance
        .collection('Groups')
        .document(groupid)
        .collection('about')
        .document(docs.documents[0].documentID)
        .updateData({'profileurl': picurl});
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        expandedHeight: 400,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            widget.name,
            style: TextStyle(color: Colors.white),
          ),
          background: photo
              ? Image.file(picture)
              : Image.network(grpurl, fit: BoxFit.cover),
        ),
      ),
      SliverFillRemaining(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      photoedit = true;
                    });
                    final image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    setState(() {
                      photo = true;
                      picture = image;
                    });
                  },
                  child: Icon(Icons.camera, size: 30.0),
                ),
                photoedit
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            uploadpic(context);
                            setState(() {
                              photoedit = false;
                            });
                          },
                          child: Icon(Icons.save),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: edit
                        ? TextField(
                            onChanged: (value) {
                              setState(() {
                                groupdesc = value;
                              });
                            },
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter Description',
                              hintStyle: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 20.0,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide().copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide().copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            groupdesc,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
                edit
                    ? GestureDetector(
                        onTap: () async {
                          final docs = await Firestore.instance
                              .collection('Groups')
                              .document(widget.groupid)
                              .collection('description')
                              .getDocuments();
                          await Firestore.instance
                              .collection('Groups')
                              .document(widget.groupid)
                              .collection('description')
                              .document(docs.documents[0].documentID)
                              .updateData({'description': groupdesc});
                          getgroupdesc();
                          setState(() {
                            edit = false;
                          });
                        },
                        child: Icon(Icons.save),
                      )
                    : Container(),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      edit = true;
                    });
                  },
                  child: Icon(Icons.edit),
                ),
              ],
            ),
            Text(
              'Members',
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('Groups')
                      .document(widget.groupid)
                      .collection('members')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final snap = snapshot.data.documents;
                    List<Namecard> persons = [];
                    if (snapshot.hasData) {
                      for (var s in snap) {
                        final member = Namecard(user: s.data['member']);
                        persons.add(member);
                      }
                    }
                    return ListView(shrinkWrap: true, children: persons);
                  }),
            ),
          ],
        ),
      ),
    ]));
  }
}

class Namecard extends StatefulWidget {
  @override
  Namecard({this.user});
  final String user;

  @override
  _NamecardState createState() => _NamecardState();
}

class _NamecardState extends State<Namecard> {
  String name = " ";
  String photourl = " ";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  getdata() async {
    final pic = await Firestore.instance
        .collection('users')
        .where('mail', isEqualTo: widget.user)
        .getDocuments();
    setState(() {
      name = pic.documents[0].data['user'];
      photourl = pic.documents[0].data['photoURL'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photourl),
          radius: 30.0,
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => chatscreen(
                  contact: widget.user,
                ),
              ),
            );
          },
          child: Container(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
