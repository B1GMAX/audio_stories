import 'package:audio_skazki/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'change_bloc.dart';
import 'edit_profile_page.dart';


class ChangeScreens extends StatelessWidget {
  const ChangeScreens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ChangeBloc>(
      create: (BuildContext context) => ChangeBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, child) {
        return StreamBuilder<bool>(
          initialData: false,
          stream: context.read<ChangeBloc>().changeScreenStream,
          builder: (context, snapshot) {
            print('snapshot.data-${snapshot.data}');
            return !snapshot.data!
                ? const UserProfileScreen()
                : const EditProfile();
          },
        );
      },
    );
  }
}
