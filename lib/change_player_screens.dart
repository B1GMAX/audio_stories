import 'package:audio_skazki/edit_player.dart';
import 'package:audio_skazki/player_bloc.dart';
import 'package:audio_skazki/player_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChangePlayerScreens extends StatelessWidget {
  const ChangePlayerScreens({Key? key, required this.onClose, required this.audioName}) : super(key: key);
  final VoidCallback onClose;
  final String audioName;
  @override
  Widget build(BuildContext context) {
    return Provider<PlayerBloc>(
      create: (BuildContext context) => PlayerBloc(audioName: audioName)..playerInit(),
      builder: (context, _) {
        return StreamBuilder<int>(
          initialData: 0,
          stream: context.read<PlayerBloc>().indexOfPlayerScreenStream,
          builder: (context, snapshot) {
            print('${snapshot.data}');
            return IndexedStack(
              index: snapshot.data!,
              children:  [
                 PlayerScreen(onClose: onClose),
               EditPlayer(),
              ],
            );
          },
        );
      },
    );
  }
}
