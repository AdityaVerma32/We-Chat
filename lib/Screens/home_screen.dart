import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/Api/apis.dart';
import 'package:we_chat/widgets/chat_user_cad.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Model/chat_user.dart';
import '../main.dart';
import 'auth/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfUser();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else
            return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.home),
            title: _isSearching
                ? TextField(
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.about.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 16, letterSpacing: 1),
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: "Eg: Name,Email",
                        hintMaxLines: 1,
                        border: InputBorder.none))
                : const Text("We Chat"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: APIs.me,
                              )));
                },
                icon: const Icon(Icons.more_vert),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // function for signing out
              APIs.signingOut(context);
            },
            child: const Icon(Icons.add_comment_rounded),
          ),
          body: StreamBuilder(
              // this line can be can be converted to a function in apis module
              stream: APIs.firestore
                  .collection('users')
                  .where('id',
                      isNotEqualTo: APIs.auth.currentUser!
                          .uid) // getting all the user except the current user
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  case ConnectionState.done:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;

                      // the bellow works as follows
                      // list is a list
                      // data? - if data is null
                      // .map - converting data into map
                      // chatuser.fromjson() - converting map type data (e) into json format
                      // .tolist() - converting the json data into list type
                      // ?? - Cheking if the list is empty()
                      // [] - is list is empty set this as e,pty list
                      list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];
                      // print("Data : ${data}");
                    }

                    // list = [];
                    if (list.isEmpty) {
                      return Center(
                        child: Text("No Connection found",
                            style: GoogleFonts.getFont('Dancing Script',
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      );
                    } else {
                      return ListView.builder(
                          //prototypeItem: CircularProgressIndicator(),
                          padding: EdgeInsets.only(top: mq.height * 0.01),
                          itemCount:
                              _isSearching ? _searchList.length : list.length,
                          // physics: BouncingScrollPhysics(),ddd
                          itemBuilder: ((context, index) {
                            return ChatUserCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : list[index],
                            );
                            // return Text(" data : ${list[index]}");
                          }));
                    }
                }
              }),
        ),
      ),
    );
  }
}
