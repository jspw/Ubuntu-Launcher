import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/colors.dart';
import 'package:launcher/src/helpers/widgets/custom_snackbar.dart';

class ErrorMessage extends CustomSnackBar {
  final BuildContext context;
  final String error;
  final int days;
  final int seconds;
  final GlobalKey<ScaffoldState> key;
  final Function fn;

// create constructor for ErrorMessage class
  ErrorMessage({
    @required this.context,
    @required this.error,
    this.fn,
    this.days: 0,
    this.seconds: 2,
    this.key,
  }) : super(
            context: context,
            message: error,
            days: days,
            seconds: seconds,
            color: dangerColor,
            key: key);
}
