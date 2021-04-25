

import 'package:flutter/material.dart';

class Page404 extends StatelessWidget {
  final String errorMessage;

  const Page404({Key key, @required this.errorMessage})
      : assert(errorMessage != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    //
    return Scaffold(
      body: Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 30.0),
        ),
      ),
    );
  }
}
