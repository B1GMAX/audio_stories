import 'dart:async';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart' show DateFormat;


const pathAudio = 'sdcard_Download_audio.aac';

class RecordingBloc {
  StreamSubscription? _playerSubscription;
  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double? _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  StreamController<String> playerTxtController = BehaviorSubject();

  Stream<String> get playerTxtStream => playerTxtController.stream;

  StreamController<bool> recorderController = BehaviorSubject();

  Stream<bool> get recorderStream => recorderController.stream;

  StreamController<bool> playerController = BehaviorSubject();

  Stream<bool> get playerStream => playerController.stream;
  bool playerChange=true;

  FlutterSoundRecorder? audioRecorder;
  FlutterSoundPlayer? audioPlayer;
  bool isRecorderInitialised = true;

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = audioPlayer!.onProgress!.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
      if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition =
          min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      final date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds,
          isUtc: true);
      final txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        _playerTxt = txt.substring(0, 8);
        playerTxtController.add(_playerTxt);

    });
  }

  Future init() async {
    audioRecorder = FlutterSoundRecorder();
    audioPlayer=FlutterSoundPlayer();
    await audioPlayer!.openAudioSession();
    await audioRecorder!.openAudioSession();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission');
    }
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    isRecorderInitialised = false;
  }

  Future record() async {
    print('record');

    await audioRecorder!.startRecorder(toFile: pathAudio);
    isRecorderInitialised = true;

    recorderController.add(isRecorderInitialised);
  }


  Future stop() async {
    print('stop');
    await audioRecorder!.stopRecorder();
    isRecorderInitialised = false;

    recorderController.add(isRecorderInitialised);
  }

  Future startPlayer() async{
    print('playerStart');
    _addListeners();
    await audioPlayer!.startPlayer(
      fromURI: pathAudio,
    );
    playerChange=false;
    playerController.add(playerChange);
  }
  Future stopPlayer()async{
    print('stopPlayer');
    await audioPlayer!.stopPlayer();
    playerChange=true;
    playerController.add(playerChange);
  }

  Future toggleRecording() async {
    if (isRecorderInitialised == false) {
      await record();
      isRecorderInitialised = true;
    } else {
      await stop();
      isRecorderInitialised = false;
    }
    recorderController.add(isRecorderInitialised);
  }

  void dispose() {
    cancelPlayerSubscriptions();
    audioPlayer!.closeAudioSession();
    audioPlayer=null;
    audioRecorder!.closeAudioSession();
    audioRecorder = null;
    isRecorderInitialised = false;
    recorderController.close();
  }
}
