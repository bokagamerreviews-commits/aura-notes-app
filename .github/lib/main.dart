import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'state/app_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  final controller = AppController();
  await controller.initialize();
  runApp(AuraNotesApp(controller: controller));
}

class AuraNotesApp extends StatelessWidget {
  final AppController controller;

  const AuraNotesApp({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = controller.themeState;
        return MaterialApp(
          title: 'Aura Notes',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: theme.activeAccent,
            scaffoldBackgroundColor: theme.scaffoldBackground,
          ),
          home: HomeScreen(controller: controller),
        );
      },
    );
  }
}
