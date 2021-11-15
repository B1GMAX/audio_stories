import 'package:audio_skazki/registered.dart';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CodeBloc {
  final TextEditingController controller = TextEditingController();

  void authWithSms(
      BuildContext context, String verificationId, String mobileNumber) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: controller.text,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (FirebaseAuth.instance.currentUser != null) {
      final users = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      users.set({
        'userNumber': mobileNumber,
      });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Registered()),
          (route) => false);
    } else {
      print('user  is null');
    }
  }

  void dispose() {
    controller.dispose();
  }
}
