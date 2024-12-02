import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  // Guardar los 20 mejores puntajes y nombres
  static Future<void> saveHighScores(List<Map<String, dynamic>> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'high_scores',
        scores
            .map((e) =>
                '${e['name']},${e['score']}') // Almacenar nombre y puntaje
            .toList());
  }

  // Obtener los 20 mejores puntajes
  static Future<List<Map<String, dynamic>>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? scores = prefs.getStringList('high_scores');
    if (scores != null) {
      return scores.map((e) {
        final parts = e.split(',');
        return {
          'name': parts[0],
          'score': int.parse(parts[1]),
        };
      }).toList();
    }
    return [];
  }

  // Agregar un nuevo puntaje y mantener solo los 20 mejores
  static Future<void> addNewScore(int score, String name) async {
    List<Map<String, dynamic>> scores = await getHighScores();

    scores.add(<String, Object>{'name': name, 'score': score});
    scores.sort(
        (a, b) => b['score'].compareTo(a['score'])); // Ordenar de mayor a menor
    if (scores.length > 20) {
      scores = scores.sublist(0, 20); // Mantener solo los 20 mejores
    }
    await saveHighScores(scores);
  }
}
