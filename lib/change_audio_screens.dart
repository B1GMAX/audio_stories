import 'package:audio_skazki/recording_bloc.dart';
import 'package:audio_skazki/recording_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'edit_audio_screen.dart';

class ChangeAudioScreens extends StatelessWidget {
  const ChangeAudioScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<RecordingBloc>(
      create: (BuildContext context) => RecordingBloc()..init(),
      builder: (context, _) {
        return StreamBuilder<int>(
          initialData: 0,
          stream: context.read<RecordingBloc>().indexOfScreenStream,
          builder: (context, snapshot) {
            print('${snapshot.data}');
            return IndexedStack(
              index: snapshot.data!,
              children: const [
                RecordingScreen(),
                EditAudioScreen(),
              ],
            );
          },
        );
      },
    );
  }
}

