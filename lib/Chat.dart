import 'ChatList.dart';
import 'frndprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'Notification.dart';

FirebaseUser loggedinUser;
double elevation = 0;
String user;
String email;

class chatscreen extends StatefulWidget {
  @override
  chatscreen({this.contact, this.picurl, this.mail});
  final contact;
  final picurl;
  final mail;
  _chatscreenState createState() => _chatscreenState();
}

class _chatscreenState extends State<chatscreen> {
  @override
  final auth = FirebaseAuth.instance;
  final message = Firestore.instance;
  final messagecontroller = TextEditingController();
  String mess;
  String docid;
  final details = DragDownDetails;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = widget.mail;
    // print(user);
    getUser();
    getMessages();
  }

  void getUser() async {
    await auth.currentUser().then((user) async {
      final url = await list
          .collection('users')
          .where('mail', isEqualTo: widget.mail)
          .getDocuments();
      setState(() {
        email = user.email;
        docid = url.documents[0].documentID;
        print(email);
      });
    });
  }

  void getMessages() async {
    await for (var snapshot
        in message.collection('messages').orderBy('time').snapshots()) {
      for (var message in snapshot.documents) {
        //print(message.data);
      }
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
                builder: (context) => frndprofile(
                    name: widget.contact,
                    profileurl: widget.picurl,
                    mail: widget.mail),
              ),
            );
          },
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage("${widget.picurl}"),
                radius: 20.0,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  widget.contact,
                ),
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
                .collection('chatroom')
                .document(user)
                .collection('messages')
                .orderBy('time')
                .snapshots(),
            builder: (context, snapshot) {
              List<MessageBubble> messageWidget = [];
              if (snapshot.hasData) {
                final messages = snapshot.data.documents.reversed;
                //print(messages);
                for (var mess in messages) {
                  if (mess.data['sender'] == email) {
                    if (mess.data['reciever'] == user) {
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
                  if (mess.data['sender'] == user) {
                    if (mess.data['reciever'] == email) {
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
          Row(children: <Widget>[
            Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: messagecontroller,
                    minLines: 1,
                    maxLines: 100,
                    //maxLength: 100,
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
                        .collection('chatroom')
                        .document(email)
                        .collection('messages')
                        .add({
                      'text': mess,
                      'sender': email,
                      'reciever': user,
                      'time': DateTime.now().toString()
                    });

                    final docs = await message
                        .collection('chatlists')
                        .document(email)
                        .collection('mail')
                        .where('mail', isEqualTo: user)
                        .getDocuments();
                    await message
                        .collection('chatlists')
                        .document(email)
                        .collection('mail')
                        .document(docs.documents[0].documentID)
                        .updateData({
                      'time': DateTime.now().toString(),
                    });
                    message
                        .collection('chatroom')
                        .document(user)
                        .collection('messages')
                        .add({
                      'text': mess,
                      'reciever': user,
                      'sender': email,
                      'time': DateTime.now().toString(),
                    });
                    final ref1 = await message
                        .collection('chatlists')
                        .document(user)
                        .collection('mail')
                        .where('mail', isEqualTo: email)
                        .getDocuments();
                    await message
                        .collection('chatlists')
                        .document(user)
                        .collection('mail')
                        .document(ref1.documents[0].documentID)
                        .updateData({
                      'time': DateTime.now().toString(),
                    });
                    final response = await notification.sendto(
                        title: '${email}',
                        body: '${mess}',
                        token: docid,
                        value: '1');
                    // print(response.body);
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.orangeAccent,
                  )),
            ),
          ]),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  @override
  MessageBubble({this.sender, this.text, this.isme});
  final text;
  final sender;
  final bool isme;
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(isme ? 30 : 5, 8, isme ? 5 : 30, 6),
        child: isme
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
                          text,
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
                          text,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
