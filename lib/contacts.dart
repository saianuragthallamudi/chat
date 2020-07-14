import 'aboutme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatList.dart';
import 'Groups.dart';
import 'HomePage.dart';
import 'profile.dart';

TabController tabController;

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatter Box'),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            elevation: 4,
            offset: Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => profile()),
                    );
                  },
                  child: Container(child: Center(child: Text('Profile'))),
                ),
              ),
              PopupMenuItem(
                  value: 2,
                  child: GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      aboutme.saveUserLoggedIn(false);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    child: Container(child: Center(child: Text('logout'))),
                  )),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              print("value:$value");
            },
            icon: Icon(Icons.list),
          ),
        ],
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.message,
                size: 20.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.group,
                size: 20.0,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          Chatlist(),
          Groups(),
        ],
      ),
    );
  }
}

// import 'aboutme.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'ChatList.dart';
// import 'Groups.dart';
// import 'HomePage.dart';
// import 'profile.dart';

// TabController tabController;
// int flag = 0;

// class Contacts extends StatefulWidget {
//   @override
//   Contacts({this.contacts, this.mails, this.urls});
//   final List<String> contacts;
//   final List<String> mails;
//   final List<String> urls;
//   _ContactsState createState() => _ContactsState();
// }

// class _ContactsState extends State<Contacts>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     tabController = TabController(length: 2, vsync: this);
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chatter Box'),
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<int>(
//             elevation: 4,
//             offset: Offset(0, 50),
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 1,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => profile()),
//                     );
//                   },
//                   child: Container(child: Center(child: Text('Profile'))),
//                 ),
//               ),
//               PopupMenuItem(
//                   value: 2,
//                   child: GestureDetector(
//                     onTap: () {
//                       FirebaseAuth.instance.signOut();
//                       aboutme.saveUserLoggedIn(false);
//                       Navigator.pushReplacement(context,
//                           MaterialPageRoute(builder: (context) => HomePage()));
//                     },
//                     child: Container(child: Center(child: Text('logout'))),
//                   )),
//             ],
//             onCanceled: () {
//               print("You have canceled the menu.");
//             },
//             onSelected: (value) {
//               print("value:$value");
//             },
//             icon: Icon(Icons.list),
//           ),
//         ],
//         backgroundColor: Colors.orange,
//         bottom: TabBar(
//           controller: tabController,
//           indicatorColor: Colors.white,
//           tabs: <Widget>[
//             Tab(
//               icon: Icon(Icons.message),
//             ),
//             Tab(
//               icon: Icon(Icons.group),
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: tabController,
//         children: <Widget>[
//           Chatlist(
//             contacts: widget.contacts,
//             urls: widget.urls,
//             mails: widget.mails,
//           ),
//           Groups(),
//         ],
//       ),
//     );
//   }
// }
