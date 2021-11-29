import 'dart:io';
import 'package:audio_skazki/recording_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'audio_information.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:rxdart/rxdart.dart';

class AudioRecordingsBloc {
  final String audioName;

  AudioRecordingsBloc({required this.audioName});

  String _playerTxt = '00:00:00';
  String _recorderTxt = '00:00:00';

  StreamSubscription? _playerSubscription;
  StreamSubscription? _recorderSubscription;

  double _maxDuration = 0.0;
  double _sliderCurrentPosition = 0.0;
  String _duration = '';
  int _waveDuration = 0;
  double? _dbLevel;

  FlutterSoundPlayer? _audioPlayer;
  bool _isRecorderInitialised = true;
  BehaviorSubject<bool> isPlayingController = BehaviorSubject();

  Stream<bool> get isPlayingStream => isPlayingController.stream;

  AudiInformation? audiInformation;

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    initializeDateFormatting();

    await _audioPlayer!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await _audioPlayer!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future startPlayer(String path) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/download-audio.aac');

    await firebase_storage.FirebaseStorage.instance
        .ref('audio/$path')
        .writeToFile(downloadToFile);
    Codec codec = Codec.aacADTS;
    await _audioPlayer!.startPlayer(
        codec: codec,
        fromURI: '${appDocDir.path}/download-audio.aac',
        whenFinished: () {
          _isRecorderInitialised = false;
          isPlayingController.add(_isRecorderInitialised);
        });
    _isRecorderInitialised = true;
    isPlayingController.add(_isRecorderInitialised);
    _audioPlayer!.logger.d('<--- startPlayer');
  }

  Future stopPlayer() async {
    print('stopPlayer');
    await _audioPlayer!.pausePlayer();
    _isRecorderInitialised = false;
    isPlayingController.add(_isRecorderInitialised);
  }

  Future playOrStop(String path) async {
    if (_audioPlayer!.isPlaying) {
      await stopPlayer();
    } else {
      await startPlayer(path);
    }
  }
}
