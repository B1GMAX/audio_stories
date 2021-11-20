import 'package:audio_skazki/recording_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_cliper.dart';
import 'custom_slider.dart';

class EditAudioScreen extends StatelessWidget {
  const EditAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return  Stack(
      children: [
        ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            height: height * 0.6,
            color: Colors.deepPurple,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: DraggableScrollableSheet(
              initialChildSize: 0.92,
              builder: (context,controller){
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset('assets/images/koly.jpg',
                        width: 300,
                        height: 320,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 40,
                            bottom: 13,
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
                      padding: const EdgeInsets.only(top: 50,bottom: 100),
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
                )
              ),
            );
          }),
        )
      ],
    );
  }
}
