import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:we_chat/Screens/auth/login_screen.dart';

import '../helper/dailogue.dart';

class APIs {
  // for authentication instance
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for firestore cloud instance
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // current user's data as saved in the users collection
  static late ChatUser me;

  // for updating users infromation from profile page
  static Future<void> updateInfo() async {
    // auth.currentUser!.uid - this gives us the user id of current user
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // for getting information of current logged in user
  static Future<void> getSelfUser() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        me = ChatUser.fromJson(value.data()!);
      } else {
        await createUser().then((value) => getSelfUser());
      }
    });
  }

  // for checking if the user exists
  static Future<bool> userExist() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser?.uid)
            .get())
        .exists;
  }

  // for creating user and saving it in authentication
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final user = ChatUser(
        name: auth.currentUser!.displayName.toString(),
        id: auth.currentUser!.uid.toString(),
        image: auth.currentUser!.photoURL.toString(),
        about: "Hey I'm using We Chat",
        createdAt: time,
        email: auth.currentUser!.email.toString(),
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .set(user.toJson());
  }

  // function for signing out and navigating to login screen
  static Future<void> signingOut(context) async {
    Dialogue.showProgressbar(context);
    await APIs.auth.signOut().then((value) {
      return GoogleSignIn().signOut().then((value) {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
    });
  }

  // updating profile pic()
  static Future<void> updateProfilePic(File file) async {
    // getting the extension of the file
    final ext = file.path.split('.').last;

    //printing the extension
    print("Extension : $ext");

    //making a refrence of the file
    final ref =
        storage.ref().child("profile_picture/${auth.currentUser!.uid}.$ext");

    // putting the file to that refrence and then printing the meta data like size of the fle
    ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
      print("Data Transferred : ${p0.bytesTransferred / 1000} Kb");
    });

    // setting currentuser's image to the url of the image saved on the firebase storage
    me.image = await ref.getDownloadURL();

    // updating the image url on firestore
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set({'image': me.image});
  }
}
