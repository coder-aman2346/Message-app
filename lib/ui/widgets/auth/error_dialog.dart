import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      titlePadding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 15, 24, 5),
      buttonPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.only(right: 15, bottom: 10),
      title: Text(
        "Invalid phone number",
      ),
      content: Text(
        "The phone number is missing or has invalid characters. Make sure you "
            "enter a digit only.",
      ),
      contentTextStyle: TextStyle(color: Colors.grey),
      actions: <Widget>[
        Builder(
          builder: (context) {
            return TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        )
      ],
    );
  }
}