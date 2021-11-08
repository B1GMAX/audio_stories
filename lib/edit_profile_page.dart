import 'dart:io';
import 'package:audio_skazki/user_information.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'change_bloc.dart';
import 'custom_cliper.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String verificationId = '';
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(children: [
          ClipPath(
            clipper: MyCustomClipper(),
            child: Container(
              height: height * 0.6,
              color: Colors.deepPurple,
            ),
          ),
          Positioned(
            child: IconButton(
              onPressed: () {
                context.read<ChangeBloc>().appBarBackButton();
              },
              icon: const Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
              ),
            ),
            left: 4,
            top: kToolbarHeight * 0.59,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40,
              ),
              child: Column(
                children: [
                  const Text(
                    'Профиль',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                  const Text('Твоя частичка',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<String>(
                      stream: context.read<ChangeBloc>().photoStream,
                      builder: (context, snapshot) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ChangeBloc>()
                                  .showChoiceDialog(context);
                            },
                            child: snapshot.data == null
                                ? Container(
                                    width: 230,
                                    height: 240,
                                    color: Colors.white.withOpacity(0.2),
                                  )
                                : Image.file(
                                    File(snapshot.data!),
                                    width: 230,
                                    height: 240,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 70,left: 70),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: context.read<ChangeBloc>().nameController,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:70,left: 70),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: context.read<ChangeBloc>().phoneController,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        context
                            .read<ChangeBloc>()
                            .save(context, verificationId);
                      },
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(color: Colors.black),
                      )),
                  const SizedBox(
                    height: 70,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Выйти из приложения',
                            style: TextStyle(color: Colors.black),
                          )),
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Удалить аккаунт',
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
