import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audio_recording_bloc.dart';
import 'custom_cliper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class AudioRecordings extends StatelessWidget {
  const AudioRecordings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('filedata')
            .snapshots(),
        builder: (context, snapshot) {
          return Provider<AudioRecordingsBloc>(
            create: (BuildContext context) =>
                AudioRecordingsBloc(audioName: '${snapshot.data!.docs[0]}')
                  ..init(),
            builder: (context, child) {
              return Stack(
                children: [
                  ClipPath(
                    clipper: MyCustomClipper(),
                    child: Container(
                      height: height * 0.6,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 20,),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        IconButton(
                          onPressed: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Аудиозаписи',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 30),
                            ),
                            Text(
                              'Все в одном месте',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15  ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                        SvgPicture.asset(
                          'assets/svg_files/drop_menu.svg',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 10, left: 10, top: 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: snapshot.hasData
                                ? ListView.builder(
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot orderData =
                                          snapshot.data!.docs[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 7, right: 7, bottom: 7),
                                        child: Container(
                                          height: 60,
                                          width: 220,
                                          color: Colors.white.withOpacity(0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.4)),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    child: StreamBuilder<bool>(
                                                      initialData: false,
                                                      stream: context.read<AudioRecordingsBloc>().isPlayingStream,
                                                      builder: (context, snapshot) {
                                                        return Container(
                                                          child: snapshot.data ==false ? const Icon(
                                                            Icons.play_arrow,
                                                            color: Colors.white,
                                                          ) :  const Icon(
                                                            Icons.pause,
                                                            color: Colors.white,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors.blueAccent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(20),
                                                          ),
                                                          height: 40,
                                                          width: 40,
                                                        );
                                                      }
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    context
                                                        .read<
                                                            AudioRecordingsBloc>()
                                                        .playOrStop(orderData[
                                                            'audioName']);
                                                  },
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                        '${orderData['audioName']}'),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }
}
