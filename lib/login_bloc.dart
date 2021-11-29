import 'dart:async';
import 'package:audio_skazki/code_screen.dart';
import 'package:audio_skazki/user_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginBloc {
  final TextEditingController phoneNumberTextController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late UserInformation user;

  Future<void> registerUser(BuildContext context) async {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumberTextController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('verificationCompleted');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed - $e');
      },
      codeSent: (String verificationId, int? resendToken) async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => CodeScreen(
                      verificationId: verificationId,
                      mobileNumber:  phoneNumberTextController.text,
                    )),
            (route) => true);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void dispose() {
    phoneNumberTextController.dispose();
  }
}
