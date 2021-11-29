import 'package:flutter/cupertino.dart';
import 'package:provider/src/provider.dart';

import 'compilations_bloc.dart';
import 'compilations_screen.dart';
import 'one_compilation.dart';
class ChangeCompilationsScreens extends StatelessWidget {
  const ChangeCompilationsScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<CompilationsBloc>(
        create: (BuildContext context) =>CompilationsBloc()..compilationInit(),
        builder: (context,_){
          return StreamBuilder<int>(
            initialData: 0,
            stream: context.read<CompilationsBloc>().indexOfScreenStream,
            builder: (context, snapshot) {
              print('${snapshot.data}');
              return IndexedStack(
                index: snapshot.data!,
                children:  const [
                  CompilationsScreen(),
                  OneCompilation(audioPath: '',),
                ],
              );
            },
          );
        },
    );
  }
}
