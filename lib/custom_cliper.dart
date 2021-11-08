import 'dart:ui';

import 'package:flutter/cupertino.dart';

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 215);
    path.quadraticBezierTo(size.width / 4, 295, size.width / 2, 313);
    path.quadraticBezierTo(3 / 4 * size.width, 330, size.width, 310);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
