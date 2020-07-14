import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'Chat.dart';
import 'Groupchat.dart';
import 'Search1.dart';
import 'frndprofile.dart';
import 'profile.dart';
import 'Details.dart';

final list = Firestore.instance;
final auth = FirebaseAuth.instance;
FirebaseUser loggedinuser;
String email;
List<String> persons = [];
List<String> names = [];
List<String> purls = [];
List<String> pmail = [];
int flag = 0;
TabController tabController;
bool spinner = true;
FirebaseMessaging firebaseMessaging = FirebaseMessaging();

class Chatlist extends StatefulWidget {
  @override
  _ChatlistState createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
  String docid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) async {
      print('OnMessage:$message');
      firebaseMessaging.onTokenRefresh;
      final notification = message['data'];
      var frndsmail = notification['title'];
      final value = notification['value'];
      if (value == 1) {
        personalchat(frndsmail);
      } else {
        groupchat(frndsmail);
      }
    }, onMessage: (Map<String, dynamic> message) async {
      print('OnMessage:$message');
    }, onResume: (Map<String, dynamic> message) async {
      print('OnMessage:$message');
      firebaseMessaging.onTokenRefresh;
      final notification = message['data'];
      var frndsmail = notification['title'];
      final value = notification['value'];
      if (value == 1) {
        personalchat(frndsmail);
      } else {
        groupchat(frndsmail);
      }
    });
    getUser();
  }

  groupchat(groupname) async {
    final grpname = await Firestore.instance
        .collection('chatlists')
        .document(email)
        .collection('groups')
        .where('Groupname', isEqualTo: groupname)
        .getDocuments();
    var grpid = grpname.documents[0].data['Groupid'];
    final grpprof = await Firestore.instance
        .collection('Groups')
        .document(grpid)
        .collection('about')
        .getDocuments();
    var grppic = grpprof.documents[0].data['profileurl'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Groupchat(
          Groupid: grpid,
          Groupname: groupname,
          Grouppic: grppic,
        ),
      ),
    );
  }

  personalchat(frndsmail) async {
    final data = await Firestore.instance
        .collection('users')
        .where('mail', isEqualTo: frndsmail)
        .getDocuments();
    var pic = data.documents[0].data['photoURL'];
    var name = data.documents[0].data['user'];

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => chatscreen(
            contact: name,
            picurl: pic,
            mail: frndsmail,
          ),
        ));
  }

  void getUser() async {
    await auth.currentUser().then((user) async {
      final url = await list
          .collection('users')
          .where('mail', isEqualTo: user.email)
          .getDocuments();
      setState(() {
        email = user.email;
        firebaseMessaging.subscribeToTopic(url.documents[0].documentID);
        docid = url.documents[0].documentID;
        // getDetails();
        print(email);
      });
    });
  }

  void getDetails() async {
    print('enterd detals');
    await for (var snaps in Firestore.instance
        .collection('chatlists')
        .document(email)
        .collection('mail')
        .orderBy('time', descending: true)
        .snapshots()) {
      print('entered for1');
      pmail = [];
      names = [];
      purls = [];
      for (var snap in snaps.documents) {
        print(snap.data['mail']);
        final urls = await Firestore.instance
            .collection('users')
            .where('mail', isEqualTo: snap.data['mail'])
            .getDocuments();
        setState(() {
          names.add(urls.documents[0].data['user']);
          pmail.add(snap.data['mail']);
          purls.add(urls.documents[0].data['photoURL']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: details.persons.length,
                itemBuilder: (context, index) {
                  return Namecard(
                    user: details.persons[index],
                    url: details.urls[index],
                    mail: details.mails[index],
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => search()),
                    );
                  },
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Namecard extends StatelessWidget {
  @override
  Namecard({this.user, this.url, this.mail});
  final String user;
  final String url;
  final String mail;

  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0)), //this right here
                    child: Container(
                      height: 450,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 400,
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.network(
                                "${url}",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            height: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => chatscreen(
                                          contact: user,
                                          picurl: url,
                                          mail: mail,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                      width: 100, child: Icon(Icons.message)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => frndprofile(
                                              name: user,
                                              profileurl: url,
                                              mail: mail)),
                                    );
                                  },
                                  child: Container(
                                      width: 100,
                                      child: Icon(Icons.info_outline)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 30.0,
          ),
        ),
        title: Text(
          user,
          style: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => chatscreen(
                contact: user,
                picurl: url,
                mail: mail,
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/rendering.dart';
// import 'Chat.dart';
// import 'Groupchat.dart';
// import 'Search1.dart';
// import 'frndprofile.dart';
// import 'profile.dart';

// final list = Firestore.instance;
// final auth = FirebaseAuth.instance;
// FirebaseUser loggedinuser;
// String email;
// List<String> persons = [];
// List<String> names = [];
// List<String> purls = [];
// List<String> pmail = [];
// int flag = 0;
// int length;
// TabController tabController;
// bool spinner = true;
// FirebaseMessaging firebaseMessaging = FirebaseMessaging();

// class Chatlist extends StatefulWidget {
//   @override
//   Chatlist({this.contacts, this.mails, this.urls});
//   List<String> contacts;
//   List<String> mails;
//   List<String> urls;
//   _ChatlistState createState() => _ChatlistState();
// }

// class _ChatlistState extends State<Chatlist> {
//   String docid;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     flag = 0;
//     firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) async {
//       print('OnMessage:$message');
//       firebaseMessaging.onTokenRefresh;
//       final notification = message['data'];
//       var frndsmail = notification['title'];
//       final value = notification['value'];
//       if (value == 1) {
//         personalchat(frndsmail);
//       } else {
//         groupchat(frndsmail);
//       }
//     }, onMessage: (Map<String, dynamic> message) async {
//       print('OnMessage:$message');
//     }, onResume: (Map<String, dynamic> message) async {
//       print('OnMessage:$message');
//       firebaseMessaging.onTokenRefresh;
//       final notification = message['data'];
//       var frndsmail = notification['title'];
//       final value = notification['value'];
//       if (value == 1) {
//         personalchat(frndsmail);
//       } else {
//         groupchat(frndsmail);
//       }
//     });
//     getUser();
//   }

//   groupchat(groupname) async {
//     final grpname = await Firestore.instance
//         .collection('chatlists')
//         .document(email)
//         .collection('groups')
//         .where('Groupname', isEqualTo: groupname)
//         .getDocuments();
//     var grpid = grpname.documents[0].data['Groupid'];
//     final grpprof = await Firestore.instance
//         .collection('Groups')
//         .document(grpid)
//         .collection('about')
//         .getDocuments();
//     var grppic = grpprof.documents[0].data['profileurl'];
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Groupchat(
//           Groupid: grpid,
//           Groupname: groupname,
//           Grouppic: grppic,
//         ),
//       ),
//     );
//   }

//   personalchat(frndsmail) async {
//     final data = await Firestore.instance
//         .collection('users')
//         .where('mail', isEqualTo: frndsmail)
//         .getDocuments();
//     var pic = data.documents[0].data['photoURL'];
//     var name = data.documents[0].data['user'];

//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => chatscreen(
//             contact: name,
//             picurl: pic,
//             mail: frndsmail,
//           ),
//         ));
//   }

//   void getUser() async {
//     await auth.currentUser().then((user) async {
//       final url = await list
//           .collection('users')
//           .where('mail', isEqualTo: user.email)
//           .getDocuments();
//       setState(() {
//         email = user.email;
//         firebaseMessaging.subscribeToTopic(url.documents[0].documentID);
//         docid = url.documents[0].documentID;
//         getDetails();
//         print(email);
//       });
//     });
//   }

//   void getDetails() async {
//     await for (var snaps in Firestore.instance
//         .collection('chatlists')
//         .document(email)
//         .collection('mail')
//         .orderBy('time', descending: true)
//         .snapshots()) {
//       flag++;
//       print(flag);
//       print('entered for1');
//       names = [];
//       purls = [];
//       pmail = [];
//       for (var snap in snaps.documents) {
//         print(snap.data['mail']);
//         print(widget.mails);
//         final urls = await Firestore.instance
//             .collection('users')
//             .where('mail', isEqualTo: snap.data['mail'])
//             .getDocuments();
//         names.add(urls.documents[0].data['user']);
//         pmail.add(snap.data['mail']);
//         purls.add(urls.documents[0].data['photoURL']);
//       }
//       setState(() {
//         names = names;
//         pmail = pmail;
//         purls = purls;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: flag > 1 ? names.length : widget.contacts.length,
//                 itemBuilder: (context, index) {
//                   print(widget.mails[index]);
//                   return Namecard(
//                     user: flag > 1 ? names[index] : widget.contacts[index],
//                     url: flag > 1 ? purls[index] : widget.urls[index],
//                     mail: flag > 1 ? pmail[index] : widget.mails[index],
//                   );
//                 }),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: <Widget>[
//               Padding(
//                 padding: EdgeInsets.all(5.0),
//                 child: FloatingActionButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => search()),
//                     );
//                   },
//                   backgroundColor: Colors.orange,
//                   child: Icon(
//                     Icons.add,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Namecard extends StatelessWidget {
//   @override
//   Namecard({this.user, this.url, this.mail});
//   final String user;
//   final String url;
//   final String mail;

//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 15.0,
//       child: ListTile(
//         leading: GestureDetector(
//           onTap: () {
//             showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return Dialog(
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(20.0)), //this right here
//                     child: Container(
//                       height: 450,
//                       child: Column(
//                         children: <Widget>[
//                           Container(
//                             height: 400,
//                             width: 300,
//                             child: Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Image.network(
//                                 "${url}",
//                                 fit: BoxFit.fill,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: 10,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: <Widget>[
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => chatscreen(
//                                           contact: user,
//                                           picurl: url,
//                                           mail: mail,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                       width: 100, child: Icon(Icons.message)),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => frndprofile(
//                                             name: user,
//                                             profileurl: url,
//                                             mail: mail),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                       width: 100,
//                                       child: Icon(Icons.info_outline)),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 });
//           },
//           child: CircleAvatar(
//             backgroundImage: NetworkImage(url),
//             radius: 30.0,
//           ),
//         ),
//         title: Text(
//           user,
//           style: TextStyle(
//               fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => chatscreen(
//                 contact: user,
//                 picurl: url,
//                 mail: mail,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
