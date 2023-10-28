import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/Screens/view_profile_screen.dart';
import 'package:we_chat/main.dart';

import '../../Screens/home_screen.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * 0.35,
        child: Stack(
          children: [
            Positioned(
              bottom: mq.height * 0.03,
              left: mq.width * 0.075,
              right: mq.width * 0.075,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.7),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: mq.height * 0.25,
                    width: mq.height * 0.25,
                    imageUrl: user.image,
                    placeholder: (context, url) {
                      printWarning("Inside Cached Network Image");
                      printWarning("Image Path : ${user.image}");
                      return CircularProgressIndicator();
                    },
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(Icons.error)),
                  )),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: mq.width * 0.07, top: mq.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(user.name,
                      style: GoogleFonts.getFont('Lato',
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ViewProfile(user: user)));
                    },
                    child: Icon(
                      Icons.info_outline,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
