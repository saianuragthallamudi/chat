import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class frndprofile extends StatefulWidget {
  frndprofile({this.name, this.profileurl, this.mail});
  final String mail;
  final String name;
  final String profileurl;

  @override
  _frndprofileState createState() => _frndprofileState();
}

class _frndprofileState extends State<frndprofile> {
  String nickname = " ";
  String bio = " ";
  @override
  void initState() {
    getuserinfo();
    super.initState();
  }

  getuserinfo() async {
    final userinfo = await Firestore.instance
        .collection("users")
        .where("mail", isEqualTo: widget.mail)
        .getDocuments();
    setState(() async {
      nickname = await userinfo.documents[0].data["nickname"];
      bio = await userinfo.documents[0].data["Bio"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.name,
                style: TextStyle(color: Colors.white),
              ),
              background: Image.network(widget.profileurl, fit: BoxFit.cover),
            ),
          ),
          SliverFillRemaining(
            child: Column(children: <Widget>[
              //  Card(
              //    elevation: 15.0,
              //      child: ListTile(
              //       leading: Text('Name',style: TextStyle(color:Colors.black38,fontSize: 15,fontWeight:FontWeight.w300),),
              //       title: Container(
              //          child: Text(widget.name,
              //            style: TextStyle(
              //                fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
              //          ),
              //        ),
              //      ),
              //    ),
              Card(
                elevation: 15.0,
                child: ListTile(
                  leading: Text(
                    'Mail',
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  title: Container(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Text(
                      widget.mail,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 15.0,
                child: ListTile(
                  leading: Text(
                    'NickName',
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  title: Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(
                      nickname,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 15.0,
                child: ListTile(
                  leading: Text(
                    'Bio',
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  title: Container(
                    padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                    child: Text(
                      bio,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
