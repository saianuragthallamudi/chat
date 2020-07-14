import 'aboutme.dart';
import 'contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'Register.dart';
import 'Search1.dart';
import 'ChatList.dart';
import 'Chat.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Details.dart';

List<String> persons = [];
List<String> mails = [];
List<String> urls = [];

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

bool passwordVisible = true;

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  void initState() {
    passwordVisible = true;
  }

  @override
  String email, user, pass;
  bool spinner = false;
  final auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chatter Box',
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/bird.jpg'),
                    width: 120.0,
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val)
                              ? null
                              : "Enter correct email";
                        },
                        decoration: TextFieldDecoraation("email"),
                      ),
                      TextFormField(
                        obscureText: passwordVisible,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: TextFieldDecoraation("password").copyWith(
                            suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        )),
                        controller: passController,
                        validator: (val) {
                          return val.length < 6
                              ? "Enter Password 6+ characters"
                              : null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    // onTap: () {
                    //  Navigator.push(context,MaterialPageRoute(  builder: (context) =>  ));
                    // },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Forgot Password?",
                          style: (TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          )),
                        )),
                  )
                ],
              ),
              TextCard(
                text: 'GetIn',
                onTap: () async {
                  setState(() {
                    spinner = true;
                  });
                  try {
                    final newUser = await auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passController.text);
                    if (newUser != null) {
                      final userinfo = await Firestore.instance
                          .collection("users")
                          .where("mail", isEqualTo: emailController.text)
                          .getDocuments();
                      aboutme.saveUserLoggedIn(true);
                      aboutme.saveUserName(userinfo.documents[0].data["user"]);
                      aboutme.saveUserEmail(userinfo.documents[0].data["mail"]);
                      final contacts = await Firestore.instance
                          .collection('chatlists')
                          .document(emailController.text)
                          .collection('mail')
                          .orderBy('time', descending: true)
                          .getDocuments();
                      for (var contact in contacts.documents) {
                        final person = await Firestore.instance
                            .collection('users')
                            .where('mail', isEqualTo: contact.data['mail'])
                            .getDocuments();
                        details.persons.add(person.documents[0].data['user']);
                        details.mails.add(person.documents[0].data['mail']);
                        details.urls.add(person.documents[0].data['photoURL']);
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Contacts(
                              // contacts: persons,
                              // mails: mails,
                              // urls: urls,
                              ),
                        ),
                      );
                    }
                    setState(() {
                      spinner = false;
                    });
                  } catch (e) {
                    print(e);
                    Alert(
                      context: context,
                      type: AlertType.error,
                      title: "Invalid Credentials",
                      desc: e.toString(),
                      buttons: [
                        DialogButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              spinner = false;
                            });
                            Navigator.pop(context);
                          },
                          width: 120,
                        )
                      ],
                    ).show();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
