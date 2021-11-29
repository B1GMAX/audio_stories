import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'one_compilation.dart';

class CompilationsBloc {
  final String pathAudio = '';
  final Codec _codec = Codec.aacMP4;
  StreamSubscription? _playerSubscription;
  FlutterSoundPlayer? _audioPlayer;
  bool isPlaying = true;

  BehaviorSubject<bool> isPlayingController = BehaviorSubject();

  BehaviorSubject<int> indexOfScreenController = BehaviorSubject();

  Stream<int> get indexOfScreenStream => indexOfScreenController.stream;

  Stream<bool> get isPlayingStream => isPlayingController.stream;

  List<OneCompilation> compilation = [const OneCompilation(audioPath: '',)];

  Future compilationInit() async {
    _audioPlayer = FlutterSoundPlayer();

    await _audioPlayer!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );

    await _audioPlayer!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future startPlayer() async {
    Codec codec = _codec;
    await _audioPlayer!.startPlayer(
        fromURI: pathAudio,
        codec: codec,
        whenFinished: () {
          isPlaying = true;
          isPlayingController.add(isPlaying);
          _audioPlayer!.logger.d('Player finished');
        });

    _audioPlayer!.logger.d('<--- startPlayer');
    isPlaying = false;
    isPlayingController.add(isPlaying);
  }

  Future stopPlayer() async {
    print('stopPlayer');
    await _audioPlayer!.pausePlayer();
    isPlaying = true;
    isPlayingController.add(isPlaying);
  }

  Future playOrStop() async {
    if (_audioPlayer!.isPlaying) {
      await stopPlayer();
    } else {
      await startPlayer();
    }
  }
  Future<void> listExample() async {
    firebase_storage.ListResult result =
    await firebase_storage.FirebaseStorage.instance.ref().listAll();

    result.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });
  }


}
