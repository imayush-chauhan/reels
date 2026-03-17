import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:reels/core/di/service_locator.dart';
import 'package:reels/firebase_options.dart';
import 'package:reels/presentation/viewmodels/reels_viewmodel.dart';
import 'package:reels/presentation/views/reels_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupServiceLocator();

  runApp(const ReelsApp());
}

class ReelsApp extends StatelessWidget {
  const ReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: ChangeNotifierProvider(
        create: (_) => sl<ReelsViewModel>(),
        child: const ReelsScreen(),
      ),
    );
  }

}
