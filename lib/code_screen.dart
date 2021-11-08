import 'package:audio_skazki/code_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodeScreen extends StatelessWidget {
  const CodeScreen({
    Key? key,
    required this.verificationId,
    required this.mobileNumber,
  }) : super(key: key);
  final String verificationId;

  final String mobileNumber;

  @override
  Widget build(BuildContext context) {
    return Provider<CodeBloc>(
      create: (BuildContext context) => CodeBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      builder: (context, child) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: context.read<CodeBloc>().controller,
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () => context
                      .read<CodeBloc>()
                      .authWithSms(context, verificationId, mobileNumber),
                  child: const Text('Write Code')),
            ],
          ),
        ),
      ),
    );
  }
}
