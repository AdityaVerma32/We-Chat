import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:we_chat/helper/dailogue.dart';
import 'package:we_chat/main.dart';
import 'package:image_picker/image_picker.dart';

import '../../Api/apis.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.home),
          title: Text("Profile",
              style: GoogleFonts.getFont('Lato', fontWeight: FontWeight.w300)),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // function for signing out

              APIs.signingOut(context);
            },
            icon: const Icon(Icons.logout_outlined),
            label: Text("Logout", style: GoogleFonts.getFont("Lato"))),
        body: SingleChildScrollView(
          child: Form(
            // form key is used to save the curent state of the form
            // _formState.currentstate will notbe nulll if there is a change in value of form
            key: _formKey,

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
              child: Column(children: [
                SizedBox(height: mq.height * 0.04),
                Stack(children: [
                  // Profile Image
                  _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.4),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            height: mq.height * 0.25,
                            width: mq.height * 0.25,
                          ))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.4),
                          child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              height: mq.height * 0.25,
                              width: mq.height * 0.25,
                              imageUrl: widget.user.image,
                              errorWidget: ((context, url, error) =>
                                  CircleAvatar(
                                      child: Icon(
                                    CupertinoIcons.person,
                                  ))))),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(
                      onPressed: () {
                        _showBottomSheet();
                      },
                      elevation: 1,
                      shape: CircleBorder(),
                      color: Colors.white,
                      child: Icon(Icons.edit),
                    ),
                  )
                ]),
                SizedBox(height: mq.height * 0.02),
                Text("test@gmail.com",
                    style: GoogleFonts.getFont("Dancing Script", fontSize: 20)),
                SizedBox(height: mq.height * 0.02),
                TextFormField(
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        hintText: "eg: Elon Musk",
                        labelText: "Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
                SizedBox(height: mq.height * 0.02),
                TextFormField(
                    // here will will change the value of me.name and button defines below will save this state
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.black,
                        ),
                        hintText: "eg: Feeling Good",
                        labelText: "About",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
                SizedBox(height: mq.height * 0.02),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * 0.5, mq.height * 0.06)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateInfo().then((value) {
                        Dialogue.showSnackBar(
                            context, "Profile updated Sucessfully");
                      });
                      print("Inside validate");
                    }
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Update",
                      style: GoogleFonts.getFont("Lato", fontSize: 18)),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(maxHeight: mq.height * 0.3),
        // shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        clipBehavior: Clip
            .antiAliasWithSaveLayer, // this line made the upper border curve

        backgroundColor: Colors.transparent,
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            margin: EdgeInsets.all(9),
            child: ListView(
              padding: EdgeInsets.only(top: mq.height * 0.03),
              children: [
                Text('Pick Profile Picture',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont('Lato',
                        fontWeight: FontWeight.w500, fontSize: 20)),
                SizedBox(height: mq.height * 0.02),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            //shape: RoundedRectangleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * 0.3, mq.width * 0.3)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            print(
                                'Image Path: ${image.path} Image Mimetype: ${image.mimeType}');
                            setState(() {
                              _imagePath = image.path;
                            });
                            APIs.updateProfilePic(File(_imagePath!));

                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset("images/Image.png")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            //shape: BeveledRectangleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(mq.width * 0.3, mq.width * 0.3)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 70);
                          if (image != null) {
                            print(
                                'Image Path: ${image.path} Image Mimetype: ${image.mimeType}');
                            setState(() {
                              _imagePath = image.path;
                            });

                            APIs.updateProfilePic(File(_imagePath!));
                            Navigator.pop(context);
                          }
                        },
                        child: Image.asset("images/camera.png")),
                  ],
                )
              ],
            ),
          );
        });
  }
}
