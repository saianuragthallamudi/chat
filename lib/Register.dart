import 'aboutme.dart';
import 'contacts.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Chat.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Search1.dart';
import 'ChatList.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

String email;

class RegisterPage extends StatefulWidget {
  @override
  String id = 'registerpage';
  _RegisterPageState createState() => _RegisterPageState();
}

bool passwordVisible;

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    passwordVisible = true;
  }

  @override
  String user, pass;
  bool spinner = false;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  final auth = FirebaseAuth.instance;
  final reguser = Firestore.instance;
  final formKey = GlobalKey<FormState>();

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
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                        controller: usernameController,
                        validator: (val) {
                          return val.isEmpty || val.length < 2
                              ? "Enter Username 3+ characters"
                              : null;
                        },
                        decoration: TextFieldDecoraation("username"),
                      ),
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
              TextCard(
                text: 'GetStarted',
                onTap: () async {
                  if (formKey.currentState.validate()) {
                    user = usernameController.text;
                    email = emailController.text;
                    pass = passController.text;
                  }
                  setState(() {
                    if (user != null && email != null && pass != null) {
                      spinner = true;
                    }
                  });
                  try {
                    AuthResult result =
                        await auth.createUserWithEmailAndPassword(
                            email: email, password: pass);
                    FirebaseUser firebaseuser = result.user;
                    await reguser.collection('users').add({
                      'user': user,
                      "mail": email,
                      'uid': firebaseuser.uid,
                      'photoURL':
                          'https://www.rd.com/wp-content/uploads/2017/09/01-shutterstock_476340928-Irina-Bg-1024x683.jpg',
                      'nickname': " ",
                      'bio': " "
                    });
                    if (firebaseuser != null) {
                      aboutme.saveUserLoggedIn(true);
                      aboutme.saveUserName(usernameController.text);
                      aboutme.saveUserEmail(emailController.text);

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Contacts(),
                          ));
                    }
                    setState(() {
                      spinner = false;
                    });
                  } catch (e) {
                    print(e);
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

InputDecoration TextFieldDecoraation(String hintText) {
  return InputDecoration(
    hintText: hintText,
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
  );
}

class UserField extends StatelessWidget {
  @override
  UserField({this.text, this.onChanged, this.textcontroller});
  final String text;
  final Function onChanged;
  final TextEditingController textcontroller;
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: TextField(
        controller: textcontroller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: text,
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
    );
  }
}
