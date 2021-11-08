import 'dart:io';

import 'package:audio_skazki/user_information.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'change_bloc.dart';
import 'custom_cliper.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 4'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(children: [
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
              _scaffoldKey.currentState!.openDrawer();
              print('loh');
            },
            icon: const Icon(
              Icons.menu,
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
            child: StreamBuilder<UserInformation>(
                initialData: context.read<ChangeBloc>().userProfile,
                stream: context.read<ChangeBloc>().getSnapshot(),
                builder: (context, snapshot) {
                  return Column(
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: snapshot.data?.userPhoto == null
                            ? Container(
                                width: 230,
                                height: 240,
                                color: Colors.white.withOpacity(0.2),
                              )
                            : Image.file(
                                File(snapshot.data!.userPhoto!),
                                width: 230,
                                height: 240,
                                fit: BoxFit.fill,
                              ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        snapshot.data?.userName == null
                            ? 'Коля'
                            : snapshot.data!.userName!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        width: 270,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 1,
                                offset: const Offset(2, 6)),
                          ],
                        ),
                        child: Center(
                            child: Text(snapshot.data?.userNumber ?? '')),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            context.read<ChangeBloc>().push();
                          },
                          child: const Text(
                            'Редактировать',
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
                  );
                }),
          ),
        ),
      ]),
    );
  }
}
