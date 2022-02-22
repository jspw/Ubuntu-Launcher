import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/colors.dart';
import 'package:launcher/src/helpers/widgets/custom_snackbar.dart';

class WarningMessage extends CustomSnackBar {
  final BuildContext context;
  final String warning;
  final int days;
  final int seconds;
  final GlobalKey<ScaffoldState> key;

// create constructor for warning class
  WarningMessage({
    @required this.context,
    @required this.warning,
    this.days,
    this.seconds,
    this.key,
  }) : super(
            context: context,
            message: warning,
            days: days,
            seconds: seconds,
            color: warningColor,
            key: key);
}
