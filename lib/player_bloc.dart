import 'package:audio_skazki/player_information.dart';
import 'package:audio_skazki/user_information.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;
import 'package:image_picker/image_picker.dart';

const pathAudio = 'sdcard/Download/audiooo.aac';

class PlayerBloc {
  StreamSubscription? _playerSubscription;
  bool isPlaying = true;
  double _maxPlayerDuration = 0.0;
  final Codec _codec = Codec.aacMP4;
  FlutterSoundPlayer? _audioPlayer;
  String _playerTxt = '00:00:00';
  double _sliderCurrentPosition = 0.0;
  String _duration = '';

  BehaviorSubject<PlayerInformation>playerInformationController = BehaviorSubject();
  Stream<PlayerInformation> get playerInformationStream =>
      playerInformationController.stream;


  BehaviorSubject<int> indexOfPlayerScreenController = BehaviorSubject();
  Stream<int> get indexOfPlayerScreenStream =>
      indexOfPlayerScreenController.stream;

  BehaviorSubject<String> durationController = BehaviorSubject();

  Stream<String> get durationStream => durationController.stream;

  TextEditingController audioPlayerNameController =
      TextEditingController(text: 'Аудиозапись 1');

  BehaviorSubject<bool> isPlayingController = BehaviorSubject();

  Stream<bool> get isPlayingStream => isPlayingController.stream;

  BehaviorSubject<double> maxPlayerDurationController = BehaviorSubject();

  Stream<double> get maxPlayerDurationStream =>
      maxPlayerDurationController.stream;

  BehaviorSubject<double> sliderCurrentPositionController = BehaviorSubject();

  Stream<double> get sliderCurrentPositionStream =>
      sliderCurrentPositionController.stream;
  BehaviorSubject<String> playerTxtController = BehaviorSubject();

  Stream<String> get playerTxtStream => playerTxtController.stream;

  Future playerInit() async {
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

  void _addListeners() {
    _playerSubscription =  _audioPlayer!.onProgress!.listen((e) {
      _maxPlayerDuration = e.duration.inMilliseconds.toDouble();
      if (_maxPlayerDuration <= 0) _maxPlayerDuration = 0.0;
      maxPlayerDurationController.add(_maxPlayerDuration);
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
      DateTime dateDuration = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      String durationTxt = DateFormat('mm:ss:SS', 'en_GB').format(dateDuration);
      _duration = durationTxt.substring(0, 5);
      durationController.add(_duration);
      playerTxtController.add(_playerTxt);
    });
  }

  Future<void> seekToPlayer(int milliSec) async {
    if (_audioPlayer!.isPlaying) {
      await _audioPlayer!.seekToPlayer(Duration(milliseconds: milliSec));
    }
    _sliderCurrentPosition = milliSec.toDouble();
    sliderCurrentPositionController.add(_sliderCurrentPosition);
  }

  Future startPlayer() async {
    Codec codec=_codec;
    await _audioPlayer!.startPlayer(
        fromURI: pathAudio,
        codec: codec,
        whenFinished: () {
          isPlaying = true;
          isPlayingController.add(isPlaying);
          _audioPlayer!.logger.d('Player finished');
        });
    _addListeners();
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

  Future<void> shareAudio() async {
    await Share.shareFiles([pathAudio]);
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

  void onSelected(BuildContext context, int item){
    switch(item){
      case 1:
        edit();
        break;
    }
  }
 final PlayerInformation? playerInformation=PlayerInformation();

  String? _imageFile;
  final StreamController<String> _playerPhotoController = BehaviorSubject();

  Stream<String> get playerPhotoStream => _playerPhotoController.stream;


  openGallery(BuildContext context) async {
    _imageFile = (await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    ))!
        .path;
    if (_imageFile != null) {
      _playerPhotoController.add(_imageFile!);
    }

    Navigator.of(context).pop();
  }
  Future<void> showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    openGallery(context);
                  },
                  child: const Text('Gallery'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  void cancel(){
    indexOfPlayerScreenController.add(0);
    print('cancel');
  }
  void ready(){
    if (playerInformation?.playerName != audioPlayerNameController.text) {
      indexOfPlayerScreenController.add(0);
      print(audioPlayerNameController.text);
    }

    if (playerInformation?.playerPhoto != _imageFile!) {
      indexOfPlayerScreenController.add(0);
    }

    playerInformation?.playerName = audioPlayerNameController.text;
    playerInformation?.playerPhoto = _imageFile;
    playerInformationController.add(playerInformation!);
    print(playerInformation?.playerName);
    print('ready');
  }
  void edit(){
    if (playerInformation?.playerPhoto == null) {
      _imageFile = 'assets/images/koly.jpg';
    } else {
      _imageFile = playerInformation?.playerPhoto;
    }
    if (playerInformation?.playerName == null) {
      audioPlayerNameController.text = '';
    } else {
      audioPlayerNameController.text = playerInformation!.playerName!;
    }
    _playerPhotoController.add(_imageFile!);
    indexOfPlayerScreenController.add(1);
    print('edit');
  }
}
