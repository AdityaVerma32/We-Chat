import 'package:flutter/material.dart';
import 'package:we_chat/Api/apis.dart';
import 'package:we_chat/Model/message_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/helper/my_date_utile.dart';
import '../main.dart';

class MessageCard extends StatefulWidget {
  Message message;

  MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.auth.currentUser!.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // received messages
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Text(
              widget.message.msg,
              style: GoogleFonts.getFont('Lato'),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormatedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          SizedBox(width: mq.width * 0.04),
          if (widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded, color: Colors.blue, size: 20)
          else
            Icon(Icons.done_all_rounded, color: Colors.grey, size: 20),
          SizedBox(width: mq.width * 0.005),
          Text(
            MyDateUtil.getFormatedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ]),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 255, 126),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Text(
              widget.message.msg,
              //widget.message.msg,
              style: GoogleFonts.getFont('Lato'),
            ),
          ),
        ),
      ],
    );
  }
}
