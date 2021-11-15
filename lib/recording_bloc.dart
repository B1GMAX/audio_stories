import 'dart:async';
import 'dart:ui';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

import 'audio_wave.dart';

const pathAudio = 'sdcard/Download/audio.aac';
const int duration = 42673;

class RecordingBloc {
  final Codec _codec = Codec.aacMP4;

  String _playerTxt = '00:00:00';
  String _recorderTxt = '00:00:00';

  StreamSubscription? _playerSubscription;
  StreamSubscription? _recorderSubscription;

  int pos = 0;
  double maxDuration = 0.0;
  double _sliderCurrentPosition = 0.0;
  String _duration = '';
  int waveDuration = 0;
  double? dbLevel;
  bool playerChange = true;

  FlutterSoundRecorder? audioRecorder;
  FlutterSoundPlayer? audioPlayer;
  bool isRecorderInitialised = true;

  List<AudioWaveBar> audioWaveBar = [];
  BehaviorSubject<List<AudioWaveBar>> audioWaveBarController =
      BehaviorSubject();

  Stream<List<AudioWaveBar>> get audioWaveBarStream =>
      audioWaveBarController.stream;

  BehaviorSubject<double> dbLevelController = BehaviorSubject();

  Stream<double> get dbLevelStream => dbLevelController.stream;

  BehaviorSubject<int> waveDurationController = BehaviorSubject();

  Stream<int> get waveDurationStream => waveDurationController.stream;

  BehaviorSubject<String> durationController = BehaviorSubject();

  Stream<String> get durationStream => durationController.stream;
  BehaviorSubject<String> recorderTxtController = BehaviorSubject();

  Stream<String> get recorderTxtStream => recorderTxtController.stream;

  BehaviorSubject<String> playerTxtController = BehaviorSubject();

  Stream<String> get playerTxtStream => playerTxtController.stream;

  BehaviorSubject<double> sliderCurrentPositionController = BehaviorSubject();

  Stream<double> get sliderCurrentPositionStream =>
      sliderCurrentPositionController.stream;

  BehaviorSubject<double> maxDurationController = BehaviorSubject();

  Stream<double> get maxDurationStream => maxDurationController.stream;

  BehaviorSubject<bool> recorderController = BehaviorSubject();

  Stream<bool> get recorderStream => recorderController.stream;

  BehaviorSubject<bool> playerController = BehaviorSubject();

  Stream<bool> get playerStream => playerController.stream;

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  void _addListeners() {
    _playerSubscription = audioPlayer!.onProgress!.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
      if (maxDuration <= 0) maxDuration = 0.0;
      maxDurationController.add(maxDuration);
      _sliderCurrentPosition = e.position.inMilliseconds.toDouble();
      if (_sliderCurrentPosition < 0.0) {
        _sliderCurrentPosition = 0.0;
      }
      sliderCurrentPositionController.add(_sliderCurrentPosition);
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          e.position.inMilliseconds,
          isUtc: true);
      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      _playerTxt = txt.substring(0, 5);
      playerTxtController.add(_playerTxt);
    });
  }

  Future init() async {
    audioRecorder = FlutterSoundRecorder();
    audioPlayer = FlutterSoundPlayer();

    initializeDateFormatting();
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission');
    }
    await audioRecorder!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );

    startRecording();

    await audioPlayer!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );

    await audioRecorder!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
    await audioPlayer!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future rewind() async {
    await audioPlayer!.seekToPlayer(
        Duration(milliseconds: _sliderCurrentPosition.toInt() - 700));
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future fastForward() async {
    await audioPlayer!.seekToPlayer(
        Duration(milliseconds: _sliderCurrentPosition.toInt() + 700));
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future<void> getRecordingDuration() async {
    _recorderSubscription = audioRecorder!.onProgress!.listen((e) {
      waveDuration = e.duration.inMicroseconds;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      _recorderTxt = txt.substring(0, 8);
      recorderTxtController.add(_recorderTxt);
      waveDurationController.add(waveDuration);
    });
  }

  Future<void> getAudioWaveBar() async {
    _recorderSubscription = audioRecorder!.onProgress!.listen((e) {
      double? value = e.decibels;
      dbLevel = 70 * (value ?? 1) / 100;
      audioWaveBar
          .add(AudioWaveBar(height: dbLevel!, color: Color(0xFF4a4a97)));
      audioWaveBarController.add(audioWaveBar);
    });
  }

  Future<void> getPlayerDuration() async {
    _playerSubscription = audioRecorder!.onProgress!.listen((e) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      String durationTxt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      _duration = durationTxt.substring(0, 5);
      durationController.add(_duration);
    });
  }

  Future<void> seekToPlayer(int milliSec) async {
    try {
      if (audioPlayer!.isPlaying) {
        await audioPlayer!.seekToPlayer(Duration(milliseconds: milliSec));
      }
    } on Exception catch (err) {
      audioPlayer!.logger.e('error: $err');
    }
    _sliderCurrentPosition = milliSec.toDouble();
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future startRecording() async {
    print('record');

    await audioRecorder!.startRecorder(
      toFile: pathAudio,
    );
    audioPlayer!.stopPlayer();
    await getRecordingDuration();
    await getAudioWaveBar();
    await getPlayerDuration();

    isRecorderInitialised = false;
    recorderController.add(isRecorderInitialised);
  }

  Future stopRecording() async {
    print('stop');
    await audioRecorder!.stopRecorder();
    _addListeners();
    audioWaveBar.clear();
    cancelRecorderSubscriptions();
    isRecorderInitialised = true;
    recorderController.add(isRecorderInitialised);
  }

  Future startPlayer() async {
    try {
      String? audioFilePath = 'sdcard/Download/audio.aac';
      Codec codec = _codec;
      await audioPlayer!.startPlayer(
          fromURI: audioFilePath,
          codec: codec,
          whenFinished: () {
            audioPlayer!.logger.d('Player finished');
          });

      audioPlayer!.logger.d('<--- startPlayer');
    } on Exception catch (err) {
      audioPlayer!.logger.e('error: $err');
    }
  }

  void pauseResumePlayer() async {
    try {
      if (audioPlayer!.isPlaying) {
        await audioPlayer!.pausePlayer();
      } else {
        await audioPlayer!.resumePlayer();
      }
    } on Exception catch (err) {
      audioPlayer!.logger.e('error: $err');
    }
  }

  Future stopPlayer() async {
    print('stopPlayer');
    await audioPlayer!.pausePlayer();
  }

  void Function()? onStopPlayerPressed() {
    return (audioPlayer!.isPlaying) ? stopPlayer : null;
  }

  void Function()? onStartPlayerPressed() {
    return (audioPlayer!.isStopped) ? startPlayer : null;
  }

  void dispose() {
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    audioPlayer!.closeAudioSession();
    audioPlayer = null;
    audioRecorder!.closeAudioSession();
    audioRecorder = null;
    isRecorderInitialised = true;
    recorderController.close();
    audioWaveBarController.close();
    waveDurationController.close();
    audioWaveBar = [];
  }
}
