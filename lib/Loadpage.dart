// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'aboutme.dart';
// import 'ChatList.dart';
// import 'contacts.dart';

// String email;
// List<String> persons = [];
// List<String> urls = [];
// List<String> mails = [];
// bool spinner = true;

// class loadpage extends StatefulWidget {
//   @override
//   _loadpageState createState() => _loadpageState();
// }

// class _loadpageState extends State<loadpage> {
//   @override
//   void initState() {
//     super.initState();
//     getUser();
//   }

//   void getUser() async {
//     email = await aboutme.getUserEmail();
//     print(email);
//     getDetails();
//   }

//   getDetails() async {
//     final contacts = await Firestore.instance
//         .collection('chatlists')
//         .document(email)
//         .collection('mail')
//         .orderBy('time', descending: true)
//         .getDocuments();
//     for (var contact in contacts.documents) {
//       final person = await Firestore.instance
//           .collection('users')
//           .where('mail', isEqualTo: contact.data['mail'])
//           .getDocuments();
//       persons.add(person.documents[0].data['user']);
//       mails.add(person.documents[0].data['mail']);
//       urls.add(person.documents[0].data['photoURL']);
//     }
//     setState(() {
//       spinner = false;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Contacts(
//             contacts: persons,
//             urls: urls,
//             mails: mails,
//           ),
//         ),
//       );
//     });
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ModalProgressHUD(
//         inAsyncCall: spinner,
//         child: Container(),
//       ),
//     );
//   }
// }
