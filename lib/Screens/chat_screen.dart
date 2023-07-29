import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/my_date_utile.dart';
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

  bool _isUploading = false;
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: WillPopScope(
            onWillPop: () {
              if (_showEmoji) {
                setState(() {
                  _showEmoji = !_showEmoji;
                });
                return Future.value(
                    false); // in case of false current screen doesn't remove
              } else {
                return Future.value(true); // Current screen do get removed
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  flexibleSpace: _appBar(),
                ),
                backgroundColor: Color.fromARGB(255, 234, 248, 255),
                body: Stack(children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            _isUploading ? mq.width * 0.28 : mq.width * 0.16),
                    child: StreamBuilder(
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

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    physics: _isUploading == true
                                        ? BouncingScrollPhysics()
                                        : null,
                                    reverse: true,
                                    padding:
                                        EdgeInsets.only(top: mq.height * 0.01),
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
                  Align(alignment: Alignment.bottomCenter, child: _chatInput()),
                ])),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {},
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
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
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
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
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: GoogleFonts.getFont('Lato',
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        list.isNotEmpty
                            ? (list[0].isOnline
                                ? "Online"
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive))
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: GoogleFonts.getFont('Lato',
                            fontSize: 10, fontWeight: FontWeight.w300),
                      )
                    ],
                  )
                ],
              );
            }));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: mq.height * 0.001),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isUploading)
            Padding(
              padding: EdgeInsets.only(
                  top: mq.height * 0.015,
                  bottom: mq.height * 0.015,
                  left: mq.width * 0.6),
              child: CircularProgressIndicator(),
            ),
          Row(
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
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        prefixIcon: IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _showEmoji = !_showEmoji;
                            });
                          },
                          icon: Icon(Icons.emoji_emotions,
                              color: Colors.lightGreen),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();

                                  // for picking multiple Images
                                  final List<XFile>? images = await picker
                                      .pickMultiImage(imageQuality: 70);

                                  // traversing the list of images and sending to other user
                                  for (var img in images!) {
                                    setState(() {
                                      _isUploading = !_isUploading;
                                    });
                                    await APIs.sendChatImage(
                                        widget.user, File(img.path));
                                    setState(() {
                                      _isUploading = !_isUploading;
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.gamepad,
                                  color: Colors.lightGreen,
                                )),
                            IconButton(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 70);
                                  if (image != null) {
                                    setState(() {
                                      _isUploading = !_isUploading;
                                    });
                                    await APIs.sendChatImage(
                                        widget.user, File(image.path));
                                    setState(() {
                                      _isUploading = !_isUploading;
                                    });
                                  }
                                },
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
                          APIs.sendMessage(
                              widget.user, _textController.text, Type.text);
                          _textController.clear();
                        }
                      }),
                ),
              )
            ],
          ),
          Container(
            child: _showEmoji
                ? SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                            bgColor: Color.fromARGB(255, 234, 248, 255),
                            columns: 7,
                            initCategory: Category.SMILEYS,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0))))
                : null,
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
