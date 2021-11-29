import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_cliper.dart';

class OneCompilation extends StatelessWidget {
  const OneCompilation({Key? key, required this.audioPath}) : super(key: key);
  final String audioPath;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            height: height * 0.6,
            color: const Color(0xFF71a59f),
          ),
        ),
        Container(
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF71a59f),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  Text('Audio name'),
                  Text('Time'),
                ],
              ),
              const SizedBox(
                width: 50,
              ),
              SvgPicture.asset(
                'assets/svg_files/drop_menu.svg',
                color: const Color(0xFF4a4a97),
              ),
            ],
          ),
        )
      ],
    );
  }
}
