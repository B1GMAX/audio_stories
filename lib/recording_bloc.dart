import 'dart:async';
import 'package:audio_skazki/screens.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';
import 'audio_wave.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

const pathAudio = 'sdcard/Download/';

class RecordingBloc {
  RecordingBloc() {
    getApplicationDocumentsDirectory().then((value) => _appDocDir = value);
  }

  final Codec _codec = Codec.aacADTS;
  late final Directory _appDocDir;

  String _playerTxt = '00:00:00';
  String _recorderTxt = '00:00:00';

  StreamSubscription? _playerSubscription;
  StreamSubscription? _recorderSubscription;

  double _maxDuration = 0.0;
  double _sliderCurrentPosition = 0.0;
  String _duration = '';
  int _waveDuration = 0;
  double? _dbLevel;
  String _audioInitialText = 'Аудиозапись';
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecorderInitialised = true;

  BehaviorSubject<int> indexOfScreenController = BehaviorSubject();

  Stream<int> get indexOfScreenStream => indexOfScreenController.stream;

  TextEditingController audioNameController =
      TextEditingController(text: 'Аудиозапись');

  final List<AudioWaveBar> _audioWaveBar = [];
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
    _playerSubscription = _audioPlayer!.onProgress!.listen((e) {
      _maxDuration = e.duration.inMilliseconds.toDouble();
      if (_maxDuration <= 0) _maxDuration = 0.0;
      maxDurationController.add(_maxDuration);
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
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();

    initializeDateFormatting();
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission');
    }
    await _audioRecorder!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );

    await startRecording();

    await _audioPlayer!.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );

    await _audioRecorder!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
    await _audioPlayer!
        .setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future rewind() async {
    await _audioPlayer!.seekToPlayer(
        Duration(milliseconds: _sliderCurrentPosition.toInt() - 700));
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future fastForward() async {
    await _audioPlayer!.seekToPlayer(
        Duration(milliseconds: _sliderCurrentPosition.toInt() + 700));
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future<void> getRecordingDuration() async {
    _recorderSubscription = _audioRecorder!.onProgress!.listen((e) {
      _waveDuration = e.duration.inMicroseconds;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      _recorderTxt = txt.substring(0, 8);
      recorderTxtController.add(_recorderTxt);
      waveDurationController.add(_waveDuration);
    });
  }

  Future<void> getAudioWaveBar() async {
    _recorderSubscription = _audioRecorder!.onProgress!.listen((e) {
      double? value = e.decibels;
      _dbLevel = 70 * (value ?? 5) / 80;
      if (_audioWaveBar.length >= 100) _audioWaveBar.removeAt(0);
      _audioWaveBar
          .add(AudioWaveBar(height: _dbLevel!, color: Color(0xFF4a4a97)));
      audioWaveBarController.add(_audioWaveBar);
    });
  }

  Future<void> getPlayerDuration() async {
    _playerSubscription = _audioRecorder!.onProgress!.listen((e) {
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
      if (_audioPlayer!.isPlaying) {
        await _audioPlayer!.seekToPlayer(Duration(milliseconds: milliSec));
      }
    } on Exception catch (err) {
      _audioPlayer!.logger.e('error: $err');
    }
    _sliderCurrentPosition = milliSec.toDouble();
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future<void> startRecording() async {
    await _audioRecorder!.startRecorder(
      codec: _codec,
      toFile: '${_appDocDir.path}/$_audioInitialText.aac',
    );
    print('record');
    _audioPlayer!.stopPlayer();
    getRecordingDuration();
    await getAudioWaveBar();
    await getPlayerDuration();

    _isRecorderInitialised = false;
    recorderController.add(_isRecorderInitialised);
  }

  Future<void> stopRecording() async {
    print('stop');
    await _audioRecorder!.stopRecorder();
    _addListeners();
    _audioWaveBar.clear();
    cancelRecorderSubscriptions();
    _isRecorderInitialised = true;
    recorderController.add(_isRecorderInitialised);
  }

  Future<void> startPlayer() async {
    await _audioPlayer!.startPlayer(
        codec: _codec,
        fromURI: '${_appDocDir.path}/$_audioInitialText.aac',
        whenFinished: () {
          _audioPlayer!.logger.d('Player finished');
        });

    _audioPlayer!.logger.d('<--- startPlayer');
  }

  void pauseResumePlayer() async {
    try {
      if (_audioPlayer!.isPlaying) {
        await _audioPlayer!.pausePlayer();
      } else {
        await _audioPlayer!.resumePlayer();
      }
    } on Exception catch (err) {
      _audioPlayer!.logger.e('error: $err');
    }
  }

  Future stopPlayer() async {
    print('stopPlayer');
    await _audioPlayer!.pausePlayer();
  }

  void Function()? onStopPlayerPressed() {
    return (_audioPlayer!.isPlaying) ? stopPlayer : null;
  }

  void Function()? onStartPlayerPressed() {
    return (_audioPlayer!.isStopped) ? startPlayer : null;
  }

  Future<void> shareAudio() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    await Share.shareFiles(['${appDocDir.path}/$_audioInitialText.aac']);
  }

  final _audioDocument = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('filedata')
      .doc();

  void uploadFile() {
    firebase_storage.FirebaseStorage.instance
        .ref('audio/${audioNameController.text}')
        .putFile(File(pathAudio + '${audioNameController.text}.aac'));
  }

  Future<void> deleteAudio() async {
    await _audioRecorder!.deleteRecord(fileName: pathAudio);
    await _audioRecorder!.closeAudioSession();
    await _audioPlayer!.closeAudioSession();
  }

  void showMaterialDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text('Подтвреждаете удаление?')),
            content: const Text(
                'Ваш файл перенесется в папку\n "Недавно удаленные"\n Через 15 дней он исчезнет'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        deleteAudio();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Screens()));
                      },
                      child: const Text('Да')),
                  TextButton(
                      onPressed: () {
                        deleteAudio();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Нет')),
                ],
              )
            ],
          );
        });
  }

  Future<void> save() async {
    if (audioNameController.text != _audioInitialText) {
      File('${_appDocDir.path}/$_audioInitialText.aac')
          .renameSync('${_appDocDir.path}/${audioNameController.text}.aac');
    }
    final oldFileName = _audioInitialText;
    if (audioNameController.text == _audioInitialText) {
      _audioInitialText += DateTime.now().toString().substring(0, 16);
      audioNameController.text = _audioInitialText;
      print(
          'file- ${File('${_appDocDir.path}/$oldFileName.aac').existsSync()}');
      File('${_appDocDir.path}/$oldFileName.aac')
          .renameSync('${_appDocDir.path}/${audioNameController.text}.aac');
    }

    _audioDocument
        .set({'audioName': audioNameController.text}, SetOptions(merge: true));
    firebase_storage.FirebaseStorage.instance
        .ref('audio/${audioNameController.text}')
        .putFile(File('${_appDocDir.path}/${audioNameController.text}.aac'));
    indexOfScreenController.add(1);
    print('save');
  }

  void onPlayerScreenClose() {
    indexOfScreenController.add(0);
    print('back');
  }

  void dispose() {
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialised = true;
    recorderController.close();
    audioWaveBarController.close();
    waveDurationController.close();
    _audioWaveBar.clear();
  }
}
