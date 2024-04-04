import 'package:flutter/material.dart';
import '../presentation/checkpoint_challenge_screen/checkpoint_challenge_screen.dart';
import '../presentation/individual_trail_page_screen/individual_trail_page_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String startPage = '/start_page';

  static const String trailsPageMyTrailsPage = '/trails_page_my_trails_page';

  static const String challengePage = '/challenge_page';

  static const String checkpointChallengeScreen =
      '/checkpoint_challenge_screen';

  static const String individualTrailPageScreen =
      '/individual_trail_page_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static Map<String, WidgetBuilder> routes = {
    checkpointChallengeScreen: (context) => CheckpointChallengeScreen(),
    individualTrailPageScreen: (context) => IndividualTrailPageScreen(),
    appNavigationScreen: (context) => AppNavigationScreen()
  };
}
