import 'package:audio_skazki/screens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audio_skazki/recording_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_wave.dart';
import 'custom_cliper.dart';
import 'custom_slider.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return StreamBuilder<bool>(
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
              // Positioned(
              //   child: IconButton(
              //     onPressed: () {
              //       _scaffoldKey.currentState!.openDrawer();
              //     },
              //     icon: const Icon(
              //       Icons.menu,
              //       color: Colors.white,
              //     ),
              //   ),
              //   left: 4,
              //   top: kToolbarHeight * 0.59,
              // ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    if (snapshot.data == true) {
                      return SingleChildScrollView(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      child: SvgPicture.asset(
                                        'assets/svg_files/upload.svg',
                                        color: const Color(0xFF4a4a97),
                                      ),
                                      onTap: () {
                                        context
                                            .read<RecordingBloc>()
                                            .shareAudio();
                                      },
                                    ),
                                    GestureDetector(
                                        child: SvgPicture.asset(
                                          'assets/svg_files/paper_download.svg',
                                          color: const Color(0xFF4a4a97),
                                        ),
                                        onTap: context
                                            .read<RecordingBloc>()
                                            .uploadFile),
                                    GestureDetector(
                                      child: SvgPicture.asset(
                                        'assets/svg_files/delete.svg',
                                        color: const Color(0xFF4a4a97),
                                      ),
                                      onTap: () {
                                        context
                                            .read<RecordingBloc>()
                                            .showMaterialDialog(context);
                                      },
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    GestureDetector(
                                        child: const Text(
                                          'Сохранить',
                                          style: TextStyle(
                                            color: Color(0xFF4a4a97),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: context
                                            .read<RecordingBloc>()
                                            .saveAndGoToEdit),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 80,
                                      bottom: 20,
                                      left: 50,
                                      right: 50),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                     enabledBorder:  InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                        color: Color(0xFF4a4a97),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25),
                                    textAlign: TextAlign.center,
                                    controller: context
                                        .read<RecordingBloc>()
                                        .audioNameController,
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 56.0,
                                    height: 50.0,
                                    child: ClipOval(
                                      child: TextButton(
                                        onPressed: context
                                            .read<RecordingBloc>()
                                            .startPlayer,
                                        //disabledColor: Colors.white,
                                        //padding: EdgeInsets.all(8.0),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Color(0xFF4a4a97),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 56.0,
                                    height: 50.0,
                                    child: ClipOval(
                                      child: TextButton(
                                        onPressed: context
                                            .read<RecordingBloc>()
                                            .pauseResumePlayer,
                                        //disabledColor: Colors.white,
                                        //padding: EdgeInsets.all(8.0),
                                        child: const Icon(
                                          Icons.pause,
                                          color: Color(0xFF4a4a97),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              StreamBuilder<double>(
                                  initialData: 0.0,
                                  stream: context
                                      .read<RecordingBloc>()
                                      .maxDurationStream,
                                  builder: (context, snapshotDuration) {
                                    return StreamBuilder<double>(
                                        initialData: 0.0,
                                        stream: context
                                            .read<RecordingBloc>()
                                            .sliderCurrentPositionStream,
                                        builder: (context,
                                            snapshotCurrentPosition) {
                                          return SliderTheme(
                                            data: const SliderThemeData(
                                              activeTrackColor:
                                              Color(0xFF4a4a97),
                                              inactiveTrackColor:
                                              Color(0xFF4a4a97),
                                              thumbShape: CustomSlider(
                                                  thumbRadius: 7),
                                            ),
                                            child: Slider(
                                                min: 0.0,
                                                max: snapshotDuration.data!,
                                                value:
                                                snapshotCurrentPosition
                                                    .data!,
                                                onChanged: (value) {
                                                  context
                                                      .read<RecordingBloc>()
                                                      .seekToPlayer(
                                                      value.toInt());
                                                }),
                                          );
                                        });
                                  }),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 265, left: 25),
                                    child: StreamBuilder<String>(
                                        initialData: '00:00',
                                        stream: context
                                            .read<RecordingBloc>()
                                            .playerTxtStream,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data!,
                                            style: const TextStyle(
                                              color: Color(0xFF4a4a97),
                                            ),
                                          );
                                        }),
                                  ),
                                  StreamBuilder<String>(
                                      initialData: '00:00',
                                      stream: context
                                          .read<RecordingBloc>()
                                          .durationStream,
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data!,
                                          style: const TextStyle(
                                            color: Color(0xFF4a4a97),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 220),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: context
                                          .read<RecordingBloc>()
                                          .rewind,
                                      child: SvgPicture.asset(
                                        'assets/svg_files/rewind.svg',
                                        color: const Color(0xFF4a4a97),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<RecordingBloc>()
                                            .startRecording();
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
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    GestureDetector(
                                      onTap: context
                                          .read<RecordingBloc>()
                                          .fastForward,
                                      child: SvgPicture.asset(
                                        'assets/svg_files/fast_forward.svg',
                                        color: const Color(0xFF4a4a97),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 250, top: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Screens()));
                                },
                                child: const Text(
                                  'Отменить',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4a4a97),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 40, bottom: 60),
                              child: Text(
                                'Запись',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4a4a97),
                                    fontSize: 20),
                              ),
                            ),
                            StreamBuilder<List<AudioWaveBar>>(
                              initialData: const [],
                              stream: context
                                  .read<RecordingBloc>()
                                  .audioWaveBarStream,
                              builder: (context, snapshotDbLevel) {
                                return StreamBuilder<int>(
                                    initialData: 0,
                                    stream: context
                                        .read<RecordingBloc>()
                                        .waveDurationStream,
                                    builder: (context, snapshot) {
                                      return AudioWave(
                                          height: 150,
                                          width: 350,
                                          spacing: 0,
                                          animationLoop: snapshot.data!,
                                          bars: snapshotDbLevel.data!);
                                    });
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 15.0,
                                ),
                                StreamBuilder<String>(
                                    initialData: '00:00',
                                    stream: context
                                        .read<RecordingBloc>()
                                        .recorderTxtStream,
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data!,
                                        style: const TextStyle(
                                          color: Color(0xFF4a4a97),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<RecordingBloc>()
                                    .stopRecording();
                              },
                              child: Container(
                                height: 75,
                                width: 75,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
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
                    }
                  },
                ),
              ),
            ],
          );
        });
  }
}
