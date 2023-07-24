import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
}
