import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_skazki/user_information.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ChangeBloc {
  UserInformation? userProfile;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final StreamController<String> _photoController = BehaviorSubject();

  Stream<String> get photoStream => _photoController.stream;

  final StreamController<bool> _changeScreensController = BehaviorSubject();

  Stream<bool> get changeScreenStream => _changeScreensController.stream;

  final _userDocument = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  Stream<UserInformation> getSnapshot() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return userStream.map((snapshot) {
      return userProfile = UserInformation.fromJson(snapshot.data() ?? {});
    });
  }

  String? _imageFile;

  bool switchScreen = false;

  void push() {
    if (userProfile?.userPhoto == null) {
      _imageFile = 'assets/images/koly.jpg';
    } else {
      _imageFile = userProfile?.userPhoto;
    }
    if (userProfile?.userName == null) {
      nameController.text = '';
    } else {
      nameController.text = userProfile!.userName!;
    }
    if (userProfile?.userNumber == null) {
      phoneController.text = 'text';
    } else {
      phoneController.text = userProfile!.userNumber!;
    }
    switchScreen = true;
    _photoController.add(_imageFile!);

    _changeScreensController.add(switchScreen);
  }

  openGallery(BuildContext context) async {
    _imageFile = (await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ))!
        .path;
    if (_imageFile != null) {
      _photoController.add(_imageFile!);
    }

    Navigator.of(context).pop();
  }

  Future<void> showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    openGallery(context);
                  },
                  child: const Text('Gallery'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  TextEditingController changeCodeTextController = TextEditingController();

  saveNewUser(BuildContext context, String verificationId) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: changeCodeTextController.text);

    await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
    if (FirebaseAuth.instance.currentUser != null) {
      switchScreen = false;
      _changeScreensController.add(switchScreen);
      _userDocument.update({'userNumber': phoneController.text});
      Navigator.of(context).pop();
    } else {
      print('user  is null');
    }
  }

  Future<void> changeCodeDialog(BuildContext context, String verificationId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextField(
                    controller: changeCodeTextController,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      saveNewUser(context, verificationId);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerNewUser(
      BuildContext context, String verificationId) async {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('verificationCompleted');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed - $e');
      },
      codeSent: (String verificationId, int? resendToken) async {
        await changeCodeDialog(context, verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void save(BuildContext context, String verificationId) {
    if (userProfile?.userNumber != phoneController.text) {
      switchScreen = true;
      registerNewUser(context, verificationId);
    } else {
      switchScreen = false;
    }
    if (userProfile?.userName != nameController.text) {
      _userDocument.update({'userName': nameController.text});
    }
    if (userProfile?.userPhoto != _imageFile!) {
      _userDocument.update({'userPhoto': _imageFile});
    }
    userProfile!.userName = nameController.text;
    userProfile!.userNumber = phoneController.text;
    userProfile!.userPhoto = _imageFile;

    _changeScreensController.add(switchScreen);
  }

  void appBarBackButton() {
    switchScreen = false;
    _changeScreensController.add(switchScreen);
  }
 Future <void> deleteUser()async{
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  void dispose() {
    _changeScreensController.close();
  }
}
