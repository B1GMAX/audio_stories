import 'package:audio_skazki/recording_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_cliper.dart';
import 'package:flutter_sound/flutter_sound.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Provider<RecordingBloc>(
      create: (BuildContext context) => RecordingBloc()..init(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, _) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: const Text('Profile'),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Item 2'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          body: StreamBuilder<bool>(
              initialData: false,
              stream: context.read<RecordingBloc>().recorderStream,
              builder: (context, snapshot) {
                return Stack(
                  children: [
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
                        },
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                      ),
                      left: 4,
                      top: kToolbarHeight * 0.59,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.8,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return snapshot.data == false
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('otmenit'),
                                      Text('zapis'),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      StreamBuilder<String>(
                                          initialData: '00:00:00',
                                          stream: context
                                              .read<RecordingBloc>()
                                              .playerTxtStream,
                                          builder: (context, snapshot) {
                                            return Text(snapshot.data!);
                                          }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      StreamBuilder<bool>(
                                          initialData: true,
                                          stream: context
                                              .read<RecordingBloc>()
                                              .playerStream,
                                          builder: (context, snapshot) {
                                            return GestureDetector(
                                              onTap: () {
                                                snapshot.data == true
                                                    ? context
                                                        .read<RecordingBloc>()
                                                        .startPlayer()
                                                    : context
                                                        .read<RecordingBloc>()
                                                        .stopPlayer();
                                              },
                                              child: Container(
                                                height: 75,
                                                width: 75,
                                                decoration: const BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(50)),
                                                ),
                                                child:   Icon(
                                                  snapshot.data == true
                                                      ? Icons.play_arrow : Icons.pause,
                                                        color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .read<RecordingBloc>()
                                              .record();
                                        },
                                        child: Container(
                                          height: 75,
                                          width: 75,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('Сохранить'),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      StreamBuilder<String>(
                                          initialData: '00:00:00',
                                          stream: context
                                              .read<RecordingBloc>()
                                              .playerTxtStream,
                                          builder: (context, snapshot) {
                                            return Text(snapshot.data!);
                                          }),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<RecordingBloc>().stop();
                                        },
                                        child: Container(
                                          height: 75,
                                          width: 75,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                          ),
                                          child: const Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                );
              }),
        );
      },
    );
  }
}
