import 'package:audio_skazki/recording_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_recordings.dart';
import 'change_audio_screens.dart';
import 'change_screens.dart';
import 'compilations_screen.dart';
import 'home_screen.dart';
import 'screens_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Screens extends StatelessWidget {
  const Screens({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return Provider<ScreensBloc>(
      create: (BuildContext context) => ScreensBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, child) {
        return StreamBuilder<int>(
            initialData: 0,
            stream: context.read<ScreensBloc>().stream,
            builder: (context, snapshot) {
              return Scaffold(
                drawer: Drawer(),
                extendBody: true,
                bottomNavigationBar: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38,
                          spreadRadius: 0,
                          blurRadius: 10),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    child: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: snapshot.data == 2
                          ? const Color(0xFFF1B488)
                          : const Color(0xFF8C68E4),
                      unselectedItemColor: const Color(0xFF858595),
                      onTap: (index) {
                        context.read<ScreensBloc>().onTaped(index);
                      },
                      currentIndex: snapshot.data!,
                      items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/svg_files/home.svg',
                            color: snapshot.data == 0
                                ? const Color(0xFF8C68E4)
                                : const Color(0xFF858595),
                          ),
                          label: 'Главная',
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/svg_files/category.svg',
                            color: snapshot.data == 1
                                ? const Color(0xFF8C68E4)
                                : const Color(0xFF858595),
                          ),
                          label: 'Подборки',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1B488),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SvgPicture.asset(
                              'assets/svg_files/voice.svg',
                              fit: BoxFit.none,
                            ),
                          ),
                          label: 'Запись',
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/svg_files/paper.svg',
                            color: snapshot.data == 3
                                ? const Color(0xFF8C68E4)
                                : const Color(0xFF858595),
                          ),
                          label: 'Аудиозаписи',
                        ),
                        BottomNavigationBarItem(
                          icon: SvgPicture.asset(
                            'assets/svg_files/profile.svg',
                            color: snapshot.data == 4
                                ? const Color(0xFF8C68E4)
                                : const Color(0xFF858595),
                          ),
                          label: 'Профиль',
                        ),
                      ],
                    ),
                  ),
                ),
                body: _getScreen(snapshot.data!),
              );
            });
      },
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 1:
        return const CompilationsScreen();
      case 2:
        return const ChangeAudioScreens();
      case 3:
        return const AudioRecordings();
      case 4:
        return const ChangeScreens();
    }
    return const HomeScreen();
  }
}
