import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:we_chat/Model/message_model.dart';
import 'package:we_chat/Screens/auth/login_screen.dart';
import 'package:we_chat/Screens/home_screen.dart';

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

  // ================== for accessing firebase Messageing ======================
  // this function is called inside getSelfUser function in APIS
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  static Future<void> gettingFirebaseMessagingToken() async {
    await fmessaging.requestPermission();

    await fmessaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        printWarning("Push Token : $value");
      }
    });
  }

// function for sending message
// this function is called from sendMesage function
  static Future<void> sendPushNotification(ChatUser user, String msg) async {
    try {
      final body = {
        "to": user.pushToken,
        "notification": {"title": user.name, "body": msg}
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAhlXLxBg:APA91bGraADBpn808Bf_kG2dtB5DeKbf0zyE6YIfRzklulh8CA2y8m_R8OINoFrfDve9SjiV7b2az6DM-9vvMmSfbBJSsjgCoPK7hGj08qPMmcW92iL3S-9DG_1GP_kMHsikXEXk0y80'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      printWarning('\n sendPuNotiifition E : $e');
    }
  }

  // for getting information of current logged in user
  // called on home page
  static Future<void> getSelfUser() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        me = ChatUser.fromJson(value.data()!);
        // bcz getting token wll take time so we called update actve status after this
        await gettingFirebaseMessagingToken();
        APIs.updateActiveStatus(true);

        printWarning('My Data : ${value.data()}');
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
        pushToken: '',
        lastActive: '',
        isOnline: false);

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
    final temp = file.path.split('.').first;
    //printing the extension
    printWarning("Extension : $ext");
    printWarning(" Name : $temp");

    //making a refrence of the file
    final ref =
        storage.ref().child("profile_picture/${auth.currentUser!.uid}.$ext");

    // putting the file to that refrence and then printing the meta data like size of the fle
    ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {
      printWarning("Data Transfered : ${p0.bytesTransferred / 1000} kb");
    });

    // setting currentuser's image to the url of the image saved on the firebase storage
    me.image = await ref.getDownloadURL();
    // updating the image url on firestore
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'image': me.image});
  }

  //******************* Message Screen Related APIS *************************

  // generating conversation id of two users for getting there chats
  // simply  I concatenated the id's of both the users who are chating
  static String getconversationID(String id) =>
      auth.currentUser!.uid.hashCode <= id.hashCode
          ? '${auth.currentUser!.uid}_${id}'
          : '${id}_${auth.currentUser!.uid}';

  // We have stored the current user through which are logged in
  // While moving from one page to another we are passing the user to whom we wish to send message as an argument through the function
  //get all message will perform function
  //1.Retrieve all the earlier messages
  // getConversationid is used to make message id from the current user and the other user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getconversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending messages and storing message to the to firestore
  static Future<void> sendMessage(ChatUser user, String msg, Type type) async {
    // Make the current time as id of the each message
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // building a message collection for saving to firestore
    final Message message = Message(
        msg: msg,
        otId: user.id,
        read:
            '', // read is kept empty and will be updated when it will pass through blue card
        type: type,
        fromId: auth.currentUser!.uid,
        sent: time);

    // creating refrence to the collection
    // If the Collection exist, ftech its refrence otherwise make a collection
    final ref =
        firestore.collection('chats/${getconversationID(user.id)}/messages/');

    // saving message to the refrence created above
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(
            user, type == Type.text ? msg.toString() : 'Image'));

    // above two line can also be written by concating
  }

  // chats(collection) --> conversation_id(doc) --> messages(collection) --> message(doc)

  // update read status by putting the value into read data
  // this message is called whenever the message passes throught blue message card
  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getconversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // getting last message for showing onto to chat user card
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getconversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // This will store the Image to Firebase Storage
  // After storing the image, We will get the download link of the image
  // athat
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting the extension of the file
    final ext = file.path.split('.').last;

    //making a refrence of the file
    final ref = storage.ref().child(
        "images/${getconversationID(chatUser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext");

    // putting the file to that refrence and then printing the meta data like size of the fle
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print("Data Transferred : ${p0.bytesTransferred / 1000} Kb");
    });

    // setting currentuser's image to the url of the image saved on the firebase storage
    final imageUrl = await ref.getDownloadURL();

    // updating the image url on firestore
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  // for getting user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }
}
