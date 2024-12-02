import 'package:flutter/material.dart';
import 'package:liamgift/game/score_manager.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tabla de mejores puntajes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1B2DA3),
      ),
      body: FutureBuilder(
        future: ScoreManager.getHighScores(), // Obtiene los puntajes guardados
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los puntajes'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay puntajes guardados'));
          }

          final highScores = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la tabla con los títulos "#", "Jugador" y "Puntaje"
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Columna # con un tamaño limitado
                    SizedBox(
                      width: 40, // Limitar el espacio de la columna #
                      child: Text(
                        '#',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Columna Jugador
                    Expanded(
                      child: Text(
                        'Jugador',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Columna Puntaje
                    SizedBox(
                      width: 80, // Limitar el espacio de la columna Puntaje
                      child: Text(
                        'Puntaje',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Lista de puntajes con numeración
              Expanded(
                child: ListView.builder(
                  itemCount: highScores.length,
                  itemBuilder: (context, index) {
                    final scoreEntry = highScores[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Mostrar el número de posición
                          SizedBox(
                            width: 40, // Limitar el espacio del #
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          // Nombre del jugador
                          Expanded(
                            child: Text(
                              scoreEntry['name'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          // Puntaje del jugador
                          SizedBox(
                            width: 80, // Limitar el espacio del Puntaje
                            child: Text(
                              scoreEntry['score'].toString(),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
