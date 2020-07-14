import 'package:flutter/material.dart';

import 'Login.dart';
import 'Register.dart';

class HomePage extends StatelessWidget {
  @override
  final String id = 'homepage';
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Chatter Box'),
          centerTitle: true,
          backgroundColor: Colors.orange),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  child: Image.asset('images/bird.jpg'),
                  width: 200.0,
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            TextCard(
              text: 'SignIn',
              onTap: () {
                Navigator.pushReplacement(context,
                   MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            TextCard(
              text: 'Register',
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TextCard extends StatelessWidget {
  TextCard({this.text, this.onTap});
  final String text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        width: double.infinity,
        height: 50.0,
        padding: EdgeInsets.all(10.0),
        //width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
