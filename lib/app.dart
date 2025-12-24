import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'features/welcome/welcome_page.dart';

class ProjectionCitationsApp extends StatelessWidget {
  const ProjectionCitationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E5BFF),
      ),
      home: const WelcomePage(),
    );
  }
}
