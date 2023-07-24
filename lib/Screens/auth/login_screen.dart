import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Api/apis.dart';
import 'package:we_chat/Screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helper/dailogue.dart';
import '../../main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double opacityLevel = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacityLevel = opacityLevel == 1 ? 0.0 : 1.0;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogue.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      // below line will remove the progressindicator
      Navigator.pop(context);

      // if the user is not null then only move to next page
      if (user != null) {
        // print("User : ${user..user}");
        // print("user Additional Information : ${user.additionalUserInfo}");

        if ((await APIs.userExist())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      // APIs.auth = FirebaseAuth.instance (APIS class)
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print("/n _signInWithGoogle : $e");
      Dialogue.showSnackBar(context, "Internet not Connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Welcome to we chat', style: GoogleFonts.lato()),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              left: mq.width * .25,
              width: mq.width * .5,
              duration: Duration(seconds: 1),
              child: AnimatedOpacity(
                opacity: opacityLevel,
                duration: const Duration(seconds: 3),
                child: Image.asset('images/chat.png'),
              )),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset(
                  'images/google.png',
                  height: mq.height * .04,
                ),
                label: RichText(
                    text: TextSpan(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        children: [
                      TextSpan(
                          text: 'Sign In with ',
                          style: GoogleFonts.lato(fontWeight: FontWeight.w400)),
                      TextSpan(
                          text: 'Google',
                          style: GoogleFonts.lato(fontWeight: FontWeight.w700))
                    ])),
              ))
        ],
      ),
    );
  }
}
