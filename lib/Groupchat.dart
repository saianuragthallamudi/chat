import 'Groupprofile.dart';
import 'groupinfo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'Notification.dart';
import 'Register.dart';

FirebaseUser loggedinUser;
double elevation = 0;
int flag = 0;
String email;

class Groupchat extends StatefulWidget {
  @override
  Groupchat({this.Groupid, this.Groupname, this.Grouppic});
  final String Groupid;
  final String Groupname;
  final String Grouppic;
  _GroupchatState createState() => _GroupchatState();
}

class _GroupchatState extends State<Groupchat> {
  @override
  final auth = FirebaseAuth.instance;
  final message = Firestore.instance;
  final messagecontroller = TextEditingController();
  String mess;
  final details = DragDownDetails;
  String groupid;

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  void getUser() async {
    try {
      final getuser = await auth.currentUser();
      if (getUser != null) {
        loggedinUser = getuser;
        setState(() {
          email = loggedinUser.email;
        });
        print(loggedinUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Groupprofile(
                      groupid: widget.Groupid,
                      name: widget.Groupname,
                      pic: widget.Grouppic)),
            );
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage("${profileurl}"),
                  radius: 20.0,
                ),
              ),
              Text(
                widget.Groupname,
              ),
            ],
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: message
                .collection('Groups')
                .document(widget.Groupid)
                .collection('messages')
                .orderBy('time')
                .snapshots(),
            builder: (context, snapshot) {
              List<MessageBubble> messageWidget = [];
              if (snapshot.hasData) {
                final messages = snapshot.data.documents.reversed;
                for (var mess in messages) {
                  final messagetext = mess.data['text'];
                  final sender = mess.data['sender'];
                  final text = MessageBubble(
                    text: messagetext,
                    sender: sender,
                    isme: email == sender,
                  );
                  messageWidget.add(text);
                }
              }
              return Expanded(
                child: ListView(
                  reverse: true,
                  children: messageWidget,
                ),
              );
            },
          ),
          Row(
            children: <Widget>[
              Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      controller: messagecontroller,
                      onChanged: (value) {
                        mess = value;
                      },
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your message here',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 17.0,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide().copyWith(
                            color: Colors.orange,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide().copyWith(
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ),
                  )),
              Expanded(
                child: GestureDetector(
                    onTap: () async {
                      messagecontroller.clear();
                      message
                          .collection('Groups')
                          .document(widget.Groupid)
                          .collection('messages')
                          .add({
                        'text': mess,
                        'sender': loggedinUser.email,
                        'time': DateTime.now().toString()
                      });
                      await message
                          .collection('Groups')
                          .document(widget.Groupid)
                          .collection('members')
                          .getDocuments()
                          .then((val) {
                        val.documents.forEach((mem) {
                          final person = mem.data['member'];
                          message
                              .collection('chatlists')
                              .document(person)
                              .collection('groups')
                              .where('Groupid', isEqualTo: widget.Groupid)
                              .getDocuments()
                              .then((docs) {
                            Firestore.instance
                                .collection('chatlists')
                                .document(person)
                                .collection('groups')
                                .document('${docs.documents[0].documentID}')
                                .updateData({
                              'time': DateTime.now().toString(),
                            });
                          });
                          if (person != email) {
                            message
                                .collection('users')
                                .where('mail', isEqualTo: person)
                                .getDocuments()
                                .then((data) {
                              final docid = data.documents[0].documentID;
                              final response = notification.sendto(
                                  title: "${widget.Groupname}",
                                  body: "$mess",
                                  token: docid,
                                  value: '2');
                            });
                          }
                        });
                      });
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.orangeAccent,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  @override
  MessageBubble({this.sender, this.text, this.isme});
  final text;
  final sender;
  final bool isme;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String name;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          widget.isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 1),
          child: Text(
            widget.sender,
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.black45,
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(
                widget.isme ? 30 : 5, 4, widget.isme ? 5 : 30, 6),
            child: widget.isme
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Material(
                          elevation: elevation,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          color: Colors.orangeAccent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 5.0),
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 8.0,
                          color: Colors.orange,
                        ),
                      ),
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage('images/logo.jpg'),
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage('images/logo.jpg'),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 8.0,
                          color: Colors.black26,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.black26,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black26,
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black26,
                        ),
                      ),
                      Flexible(
                        child: Material(
                          elevation: elevation,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          color: Colors.black45,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 5.0),
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
      ],
    );
  }
}
