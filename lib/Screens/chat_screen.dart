import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Api/apis.dart';
import '../Model/chat_user.dart';
import '../Model/message_model.dart';
import '../main.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
            body: Stack(children: [
              Padding(
                padding: EdgeInsets.only(bottom: mq.width * 0.16),
                child: StreamBuilder(
                    // this line can be can be converted to a function in apis module
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        case ConnectionState.done:
                        case ConnectionState.active:
                          final data = snapshot.data?.docs;
                          //print('Data : ${jsonEncode(data![0].data())}');
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          // _list.add(Message(
                          //     msg: 'msg',
                          //     read: '',
                          //     otId: 'otId',
                          //     type: Type.text,
                          //     sent: '12:00 AM',
                          //     fromId: APIs
                          //         .auth.currentUser!.uid)); // you are the sender
                          // _list.add(Message(
                          //     msg: 'Hello',
                          //     read: '',
                          //     otId: 'me',
                          //     type: Type.text,
                          //     sent: '6:00 AM',
                          //     fromId: 'other'));

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                itemCount: _list.length,
                                itemBuilder: ((context, index) {
                                  return MessageCard(message: _list[index]);
                                  // return Text(" data : ${list[index]}");
                                }));
                          } else {
                            return Center(
                              child: Text("Say Hello!!😊",
                                  style: GoogleFonts.getFont('Lato',
                                      fontSize: 20)),
                            );
                          }
                      }
                    }),
              ),
              Align(alignment: Alignment.bottomCenter, child: _chatInput())
            ])),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black54,
              )),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.user.image,
              height: mq.height * 0.05,
              width: mq.height * 0.05,
              errorWidget: ((context, url, error) =>
                  const CircleAvatar(child: Icon(Icons.person))),
            ),
          ),
          SizedBox(width: mq.width * 0.03),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.name,
                style: GoogleFonts.getFont('Lato',
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "Last Seen Not Available",
                style: GoogleFonts.getFont('Lato',
                    fontSize: 10, fontWeight: FontWeight.w300),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: mq.height * 0.001),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            //decoration: BoxDecoration(color: Colors.grey),
            width: mq.width * 0.8,
            child: Card(
              margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _textController,
                maxLines: 5,
                minLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a message",
                    prefixIcon: IconButton(
                      onPressed: () {},
                      icon:
                          Icon(Icons.emoji_emotions, color: Colors.lightGreen),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.attach_file,
                              color: Colors.lightGreen,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.camera_alt,
                                color: Colors.lightGreen))
                      ],
                    ),
                    contentPadding: EdgeInsets.all(5)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CircleAvatar(
              backgroundColor: Colors.lightGreen,
              radius: 23,
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      APIs.sendMessage(widget.user, _textController.text);
                      _textController.clear();
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }

  // Widget _chatInput() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //         horizontal: mq.width * 0.02, vertical: mq.height * 0.01),
  //     child: Row(
  //       children: [
  //         Expanded(
  //             child: Card(
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //           child: Row(children: [
  //             IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.emoji_emotions,
  //                     color: Colors.lightGreen)),
  //             Expanded(
  //                 child: TextField(
  //               keyboardType: TextInputType.,
  //               maxLines: null,
  //               decoration: InputDecoration(
  //                   hintText: "Enter Text...", border: InputBorder.none),
  //             )),
  //             IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.image, color: Colors.lightGreen)),
  //             IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.camera_alt_rounded,
  //                     color: Colors.lightGreen))
  //           ]),
  //         )),
  //         MaterialButton(
  //           minWidth: 0,
  //           height: mq.height * 0.055,
  //           color: Colors.lightGreen,
  //           shape: CircleBorder(),
  //           onPressed: () {},
  //           child: Icon(
  //             Icons.send,
  //             color: Colors.white,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}
