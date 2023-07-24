import 'package:flutter/material.dart';

class Dialogue {
  static void showSnackBar(BuildContext context, String arg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(arg),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: CircularProgressIndicator(),
            ));
  }
}
