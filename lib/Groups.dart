import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Groupadd.dart';
import 'Groupchat.dart';

final auth = FirebaseAuth.instance;
final store = Firestore.instance;
FirebaseUser loggedinuser;
List<String> gname = [];
List<String> gurls = [];
List<String> gid=[];
String email;
String groupname;

class Groups extends StatefulWidget {
  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
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
        getDetails();
      });
    }
  }
  void getDetails() async {
    await for (var snaps in Firestore.instance
        .collection('chatlists')
        .document(email)
        .collection('groups')
        .orderBy('time', descending: true)
        .snapshots()) {
      print('entered for1');
      gname =[];
      gid = [];
      gurls = [];
      for (var snap in snaps.documents) {
        print(snap.data['Groupid']);
        final urls = await Firestore.instance
            .collection('Groups').document(snap.data['Groupid']).collection('about')
            .getDocuments();
        setState(() {
          gname.add(snap.data['Groupname']);
          gid.add(snap.data['Groupid']);
          gurls.add(urls.documents[0].data['profileurl']);
        });
      }
    }
  }

  bool isSelected = false;
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
       Expanded(child: ListView.builder(
            shrinkWrap: true,
            itemCount: gname.length,
            itemBuilder: (context, index) {
              return Namecard(
                id: gid[index],
                url: gurls[index],
                name: gname[index],
              );
            }),),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: FloatingActionButton(
                backgroundColor: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Addmembers(),
                    ),
                  );
                },
                child: Icon(
                  Icons.group_add,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}


class Namecard extends StatelessWidget {
  @override
  Namecard({this.id, this.url,this.name});
  final String id;
  final String url;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage("${url}"),
          radius: 22.0,

        ),
        title: Text(
          name,
          style: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Groupchat(
                Groupid: id,
                Groupname:name,
                Grouppic:url,
              ),
            ),
          );
        },
        onLongPress: () {
          print('pressed');
        },
      ),
    );
  }



}
