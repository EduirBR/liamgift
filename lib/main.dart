import 'package:flutter/material.dart';
import 'package:liamgift/screens/home_screen.dart';
import 'package:liamgift/screens/scoreboard_screen.dart';
// import 'package:liamgift/game/game_screen.dart';
import 'package:liamgift/screens/start_screen.dart';

void main() {
  runApp(const LiamGiftApp());
}

class LiamGiftApp extends StatelessWidget {
  const LiamGiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liam Gift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/scores': (context) => const ScoreboardScreen(),
      },
    );
  }
}
