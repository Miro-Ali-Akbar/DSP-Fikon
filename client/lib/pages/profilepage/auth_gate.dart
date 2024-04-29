import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import 'profile_page.dart';

class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String webClientID = FlutterConfig.get('WEB_CLIENT_ID');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              GoogleProvider(
                clientId: webClientID
              ),
            ],
            showAuthActionSwitch: false,
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(Icons.lock),
                ),
              );
            },
          );
        }

        return const ProfilePage();
      },
    );
  }
}
