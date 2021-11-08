import 'dart:async';


import 'package:audio_skazki/recording_screen.dart';
import 'package:audio_skazki/user_information.dart';
import 'package:audio_skazki/user_profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audio_skazki/compilations_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'change_screens.dart';
import 'home_screen.dart';

class ScreensBloc {
  final List<Widget> screens = <Widget>[
    const HomeScreen(),
    const CompilationsScreen(),
    const RecordingScreen(),
    const Icon(
      Icons.description,
      size: 150,
    ),
  const ChangeScreens(),
  ];


  final StreamController<int> _controller = StreamController<int>();

  Stream<int> get stream => _controller.stream;
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void onTaped(int index) {

    _selectedIndex = index;
    _controller.add(index);
  }

  void dispose() {
    _controller.close();
  }
}
