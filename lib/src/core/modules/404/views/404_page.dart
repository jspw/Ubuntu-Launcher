import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/colors.dart';
import 'package:launcher/src/config/constants/size.dart';

class Page404 extends StatelessWidget {
  final String errorMessage;

  const Page404({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: dangerColor, fontSize: normalTextSize),
        ),
      ),
    );
  }
}
