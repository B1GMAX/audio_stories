import 'package:audio_skazki/compilations_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_cliper.dart';

class CompilationsScreen extends StatelessWidget {
  const CompilationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return
      Stack(
        children: [
          ClipPath(
            clipper: MyCustomClipper(),
            child: Container(
              height: height * 0.6,
              color: const Color(0xFF71a59f),
            ),
          ),

        ],
      );
  }
}
