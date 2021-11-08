import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompilationsScreen extends StatelessWidget {
  const CompilationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(child: Container(
        height: 100,
        width: 200,
        color: Colors.white,
        child: const Text('Text'),
      )),
    );
  }
}
