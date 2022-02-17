import 'package:flutter/material.dart';
import 'package:launcher/src/config/constants/colors.dart';
import 'package:launcher/src/config/constants/size.dart';

class Page404 extends StatelessWidget {
  final String errorMessage;

  const Page404({Key key, @required this.errorMessage})
      : assert(errorMessage != null),
        super(key: key);

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
