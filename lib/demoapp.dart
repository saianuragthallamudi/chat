import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  String phoneno;
  String otp;
  String vid;

  Future<void> SendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneno,
        timeout: Duration(seconds: 10),
        verificationCompleted: (firebaseUser) {
          print('verified');
          //ssprint(vid);
        },
        verificationFailed: (exception) {
          print('${exception.message}');
        },
        codeSent: (smscode, [ForceResendingToken]) {
          vid = smscode;
          print(vid);
          Verificationdialogue(context);
        },
        codeAutoRetrievalTimeout: (verid) {
          vid = verid;
        });
  }

  Verificationdialogue(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter OTP'),
            content: TextField(
              onChanged: (value) {
                otp = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                    } else {
                      signinWithOTP(otp, vid);
                    }
                  });
                },
                child: Text('Done'),
              )
            ],
          );
        });
  }

  signinWithOTP(String smscode, String verificationcode) {
    AuthCredential authcred = PhoneAuthProvider.getCredential(
      verificationId: verificationcode,
      smsCode: smscode,
    );
    print(verificationcode);
    print(smscode);
    signin(authcred);
  }

  signin(AuthCredential authCredential) {
    FirebaseAuth.instance.signInWithCredential(authCredential);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DemoApp'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: TextField(
              onChanged: (value) {
                phoneno = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter mobile number',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide().copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          RaisedButton(
            onPressed: SendOTP,
            child: Text(
              'Send OTP',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
