import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/plan_provider.dart';
import 'providers/user_provider.dart';
import 'providers/post_composer_provider.dart';
import 'services/notification/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostComposerProvider()),
      ],
      child: const AppRoot(),
    ),
  );
}