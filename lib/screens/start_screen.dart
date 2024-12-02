import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liamgift/game/score_manager.dart';
import 'package:liamgift/screens/home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double characterX = 0;
  List<Map<String, double>> gifts = [];
  List<Map<String, double>> damageObjects = [];
  int score = 0;
  int collectedGifts = 0;
  double giftFallSpeed = 0.02;
  int life = 3;
  Timer? giftTimer;
  Timer? damageTimer;
  Timer? gameLoopTimer;
  int countdown = 3;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    // Cancelar todos los timers si están activos
    giftTimer?.cancel();
    damageTimer?.cancel();
    gameLoopTimer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          if (countdown > 1) {
            countdown--;
          } else {
            timer.cancel();
            startGame();
          }
        });
      }
    });
  }

  void startGame() {
    setState(() {
      gameStarted = true;
    });

    giftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          gifts.add({
            'x': Random().nextDouble() * (1 - 0.1) - 0.5,
            'y': 0,
          });
        });
      }
    });

    damageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          damageObjects.add({
            'x': Random().nextDouble() * (1 - 0.1) - 0.5,
            'y': 0,
          });
        });
      }
    });

    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        // Verificar si el widget sigue montado
        setState(() {
          for (int i = 0; i < gifts.length; i++) {
            gifts[i]['y'] = gifts[i]['y']! + giftFallSpeed;
            if ((gifts[i]['x']! - characterX).abs() < 0.2 &&
                gifts[i]['y']! > 0.7) {
              gifts.removeAt(i);
              score++;
              collectedGifts++;
              if (collectedGifts % 15 == 0) {
                giftFallSpeed += 0.005;
              }
              break; // Salir del bucle después de eliminar un regalo
            }
          }

          for (int i = 0; i < damageObjects.length; i++) {
            damageObjects[i]['y'] = damageObjects[i]['y']! + giftFallSpeed;
            if ((damageObjects[i]['x']! - characterX).abs() < 0.2 &&
                damageObjects[i]['y']! > 0.7) {
              damageObjects.removeAt(i);
              life--;
              if (life <= 0) {
                endGame();
              }
              break; // Salir del bucle después de eliminar un objeto dañino
            }
          }

          gifts.removeWhere((gift) => gift['y']! > 1);
          damageObjects.removeWhere((obj) => obj['y']! > 1);
        });
      }
    });
  }

  void endGame() async {
    gameLoopTimer?.cancel();
    giftTimer?.cancel();
    damageTimer?.cancel();

    // Verificar si el puntaje está en los mejores 20
    List<Map<String, dynamic>> highScores = await ScoreManager.getHighScores();

    if (mounted) {
      if (highScores.length < 20 || highScores.last['score'] < score) {
        String playerName = '';
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "¡Game Over!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Puntaje: $score",
                    style: const TextStyle(fontSize: 18),
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Ingresa tu nombre"),
                    onChanged: (text) {
                      playerName = text;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Guardar"),
                  onPressed: () async {
                    if (playerName.isNotEmpty) {
                      await ScoreManager.addNewScore(score, playerName);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pop(); // Volver atrás
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    }
                    resetGame(); // Reiniciar el juego después de guardar el puntaje
                  },
                ),
              ],
            );
          },
        );
      } else {
        Navigator.of(context).pop(); // Cerrar diálogo
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        resetGame(); // Reiniciar el juego si no está en el ranking
      }
    }
  }

  void resetGame() {
    setState(() {
      score = 0;
      life = 3;
      characterX = 0;
      gifts.clear();
      damageObjects.clear();
      countdown = 3;
      gameStarted = false;
      collectedGifts = 0;
      giftFallSpeed = 0.02;
    });
  }

  void moveCharacter(DragUpdateDetails details) {
    setState(() {
      characterX += details.delta.dx / MediaQuery.of(context).size.width;
      if (characterX < -1) characterX = -1;
      if (characterX > 1) characterX = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Puntos: $score',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B2DA3),
      ),
      body: GestureDetector(
        onPanUpdate: moveCharacter,
        child: Stack(
          children: [
            Container(color: const Color.fromARGB(255, 245, 236, 117)),
            if (!gameStarted)
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      countdown > 0 ? '$countdown' : '¡Comienza!',
                      style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            // Mostrar los regalos
            if (gameStarted)
              ...gifts.map((gift) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * gift['y']!,
                  left: MediaQuery.of(context).size.width * (0.5 + gift['x']!) -
                      25,
                  child: const Icon(Icons.card_giftcard,
                      size: 50, color: Colors.red),
                );
              }),
            // Mostrar los objetos que hacen daño
            if (gameStarted)
              ...damageObjects.map((obj) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * obj['y']!,
                  left: MediaQuery.of(context).size.width * (0.5 + obj['x']!) -
                      25,
                  child: const Icon(Icons.api_rounded,
                      size: 50, color: Colors.black),
                );
              }),
            // Mostrar los corazones de vida
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: List.generate(life, (index) {
                  return const Icon(Icons.favorite,
                      color: Colors.red, size: 30);
                }),
              ),
            ),
            // Mostrar el personaje
            Positioned(
              bottom: 5,
              left: MediaQuery.of(context).size.width * (0.5 + characterX) - 75,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('assets/player.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
