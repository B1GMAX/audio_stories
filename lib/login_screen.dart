import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_bloc.dart';


class Login extends StatelessWidget {
   const Login({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Provider<LoginBloc>(
      create: (BuildContext context)=>LoginBloc(),
      dispose: (context,bloc)=>bloc.dispose(),
      builder: (context,child){
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  textAlign: TextAlign.center,
                  controller: context.read<LoginBloc>().phoneNumberTextController,
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(onPressed: () {
                  context.read<LoginBloc>().registerUser(context);

                }, child: const Text('login'))
              ],
            ),

          ),
        );
      },

    );

  }
}
