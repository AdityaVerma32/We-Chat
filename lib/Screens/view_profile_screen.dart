import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'home_screen.dart';

class ViewProfile extends StatelessWidget {
  final ChatUser user;
  ViewProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Container(
        height: mq.height,
        width: mq.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: mq.height * 0.05),
          ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.4),
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
          SizedBox(height: mq.height * 0.05),
          Text(user.email,
              style: GoogleFonts.getFont('Lato', fontWeight: FontWeight.w500)),
          SizedBox(height: mq.height * 0.01),
          Text("About ${user.about}",
              style: GoogleFonts.getFont('Lato', fontWeight: FontWeight.bold)),
          SizedBox(height: mq.height * 0.35),
          Text("By Aditya Verma",
              style: GoogleFonts.getFont('Lato',
                  color: Colors.purple.shade800, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}
