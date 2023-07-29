import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/Api/apis.dart';
import 'package:we_chat/Screens/home_screen.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), () {
      // below line will enable the notch
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      //below line will make the notch transparent
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark));

      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg3.jpg"), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Positioned(
              top: mq.height * .15,
              right: mq.width * 0.25,
              width: mq.width * .5,
              child: Image(image: AssetImage("images/chat.png")),
            ),
            Positioned(
                bottom: mq.height * .15,
                width: mq.width,
                child: Center(
                    child: Text(
                  "Welcome To the We Chat".toUpperCase(),
                  style: GoogleFonts.getFont('Dancing Script',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),

                  //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )))
          ],
        ),
      ),
    );
  }
}
