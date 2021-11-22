import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio_recording_bloc.dart';
import 'custom_cliper.dart';

class AudioRecordings extends StatelessWidget {
  const AudioRecordings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    return Provider<AudioRecordingsBloc>(
      create: (BuildContext context) => AudioRecordingsBloc(),
      builder: (context, child) {
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
                padding: const EdgeInsets.only(right: 10,left: 10),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  builder:
                      (BuildContext context, ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('Аудиозаписи'),
                          Expanded(
                            child: ListView.builder(

                              itemCount: context.read<AudioRecordingsBloc>().items.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 30,
                                  color: Colors.white,
                                  child: Text(context.read<AudioRecordingsBloc>().items[index]),
                                );
                              },
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

      },
    );
  }
}
