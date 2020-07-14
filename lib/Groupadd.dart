import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final auth = FirebaseAuth.instance;
final store = Firestore.instance;
FirebaseUser loggedinuser;
String email;
List<String> members = [];
List<String> selected = [];
TextEditingController textEditingController;
String groupname = '';
String groupid = '';
bool spinner = false;

class Addmembers extends StatefulWidget {
  @override
  _AddmembersState createState() => _AddmembersState();
}

class _AddmembersState extends State<Addmembers> {
  File profilepic;
  String profileurl = " https://wallpapercave.com/w/wp2553455";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  void getUser() async {
    final user = await auth.currentUser();
    if (user != null) {
      loggedinuser = user;
      setState(() {
        email = loggedinuser.email;
      });
    }
  }

  @override
  Future getimage() async {
    var newimage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilepic = newimage;
    });
  }

  Future uploadpic(BuildContext content, groupid) async {
    final StorageReference firebaseref =
        FirebaseStorage.instance.ref().child('groupprofile');
    StorageUploadTask task = firebaseref
        .child("pic" + DateTime.now().toString())
        .putFile(profilepic);
    StorageTaskSnapshot snapshot = await task.onComplete;
    profileurl = await snapshot.ref.getDownloadURL();
    updateprofilepic(profileurl, groupid);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Members',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 2,
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage('${profileurl}'),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                getimage();
                              },
                              child: Icon(Icons.add_a_photo),
                            )),
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: textEditingController,
                            onChanged: (value) {
                              groupname = value;
                              groupid = value + email;
                            },
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter group name',
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
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder(
                      stream: store
                          .collection('chatlists')
                          .document(email)
                          .collection('mail')
                          .snapshots(),
                      builder: (context, snapshots) {
                        List<Members> mem = [];
                        if (snapshots.hasData) {
                          final snap = snapshots.data.documents;
                          for (var name in snap) {
                            final member = Members(
                              mail: name.data['mail'],
                            );
                            mem.add(member);
                          }
                        }
                        return Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: mem,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () async {
                    if (selected != []) {
                      uploadpic(context, groupid);
                      setState(() {
                        spinner = true;
                      });
                      selected.add(email);
                      for (var v in selected) {
                        await store
                            .collection('chatlists')
                            .document(v)
                            .collection('groups')
                            .add({
                          'Groupname': groupname,
                          'Groupid': groupid,
                          'time': DateTime.now().toString(),
                        });
                        print(v);
                        await Firestore.instance
                            .collection('Groups')
                            .document(groupid)
                            .collection('members')
                            .add({'member': v});
                      }
                      await store
                          .collection('Groups')
                          .document(groupid)
                          .collection('about')
                          .add({'profileurl': profileurl});
                      await Firestore.instance
                          .collection('Groups')
                          .document(groupid)
                          .collection('description')
                          .add({'description': " "});
                      selected = [];
                      Navigator.pop(context);
                      setState(() {
                        spinner = false;
                      });
                    } else {
                      setState(() {
                        spinner = false;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Create Group',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Members extends StatefulWidget {
  @override
  Members({this.mail});
  final mail;
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  String name = " ";
  String profileurl = " ";
  @override
  void initState() {
    getusername();
    super.initState();
  }

  getusername() async {
    final userinfo = await Firestore.instance
        .collection("users")
        .where("mail", isEqualTo: widget.mail)
        .getDocuments();
    setState(() {
      name = userinfo.documents[0].data["user"];
      profileurl = userinfo.documents[0].data["photoURL"];
    });
  }

  @override
  bool isSelected = false;
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      title: Row(
        children: <Widget>[
          SizedBox(width: 25),
          CircleAvatar(
            backgroundImage: NetworkImage("${profileurl}"),
            radius: 20.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          )
        ],
      ),
      activeColor: Colors.orange,
      checkColor: Colors.white,
      onChanged: (bool newValue) {
        setState(() {
          isSelected = newValue;
        });
        if (isSelected) {
          selected.add(widget.mail);
        } else {
          selected.remove(widget.mail);
        }
      },
    );
  }
}

Future updateprofilepic(picurl, groupid) async {
  var userInfo = new UserUpdateInfo();
  userInfo.photoUrl = picurl;
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
