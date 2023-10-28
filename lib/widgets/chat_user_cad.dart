import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/Api/apis.dart';
import 'package:we_chat/Model/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/Screens/chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/helper/my_date_utile.dart';
import 'package:we_chat/widgets/dialogs/profile_dialog.dart';
import '../Model/message_model.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04, vertical: mq.height * 0.001),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;

                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                if (list.isNotEmpty) _message = list[0];

                return ListTile(
                    horizontalTitleGap: mq.height * 0.02,
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.05),
                        child: CachedNetworkImage(
                            // width: mq.height * 0.3,
                            // height: mq.width * 0.3,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, Error) =>
                                const CircleAvatar(child: Icon(Icons.error))),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: Text(
                      _message != null
                          ? (_message!.type == Type.image
                              ? 'Image'
                              : _message!.msg)
                          : widget.user.about,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId !=
                                    APIs.auth.currentUser!
                                        .uid // if the read time is sill empty
                            ? Container(
                                height: mq.height * 0.01,
                                width: mq.height * 0.01,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.red.shade900,
                                ),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context,
                                    time: _message!
                                        .sent), // this the time the sender sent the message
                                style: GoogleFonts.getFont('Lato'),
                              ));
              })),
    );
  }
}
