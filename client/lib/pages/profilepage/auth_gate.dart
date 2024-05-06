import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'profile_page.dart';

/// Checks if the user is logged in. Either forces you to login or takes you to the profilepage
/// Note: Use this to go to the profilepage instead of calling said class
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
              GoogleProvider(clientId: webClientID),
            ],
            showAuthActionSwitch: false,
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: EdgeInsets.all(20),
                  child:
                      Image.asset('assets/images/Logo.png'),
              );
            },
            footerBuilder: (buildContext, AuthAction) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5), // +5 for some reason
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                      child: Text(
                        'By logining in to trailquest you agree to us having access to information such as your google name and profile image. To remove said account do so at user profile page',
                        style: TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return ProfilePage();
      },
    );
  }
}
