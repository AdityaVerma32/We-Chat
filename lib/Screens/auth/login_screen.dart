import 'package:flutter/material.dart';
import 'package:we_chat/Screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

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
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
