import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/size.dart';
import 'package:logger/logger.dart';

class CustomSnackBar {
  final BuildContext context;
  final String message;
  final int days;
  final int seconds;
  final Color color;
  final Function fn;
  final GlobalKey<ScaffoldState> key;

  CustomSnackBar({
    @required this.context,
    @required this.message,
    this.seconds: 2,
    this.fn,
    this.days: 0,
    this.color,
    this.key,
  });

  display() {
    final snackBar = SnackBar(
      margin: const EdgeInsets.all(10),
      behavior: SnackBarBehavior.floating,
      duration: Duration(days: days, seconds: seconds),
      backgroundColor: color,
      content: GestureDetector(
        onTap: fn,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(
                  message,
                  overflow: TextOverflow.visible,
                  style: TextStyle(fontSize: smallTextSize),
                ),
              )
            ],
          ),
        ),
      ),
    );

    if (key != null) {
      return key.currentState.showSnackBar(snackBar);
    } else
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
