import 'package:flutter/material.dart';
import 'package:shuttle_v1/account.dart';
import 'package:shuttle_v1/ui/sign_in.dart';
import 'package:shuttle_v1/ui/bus_ui.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        //checking sign in status
        stream: Account().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const BusUi();
          } else {
            return SignIn();
          }
        },
      ),
    );
  }
}
