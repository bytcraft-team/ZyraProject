import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/week_info.dart';

class WeekDataService {
  static const String _baseUrl =
      'https://6a1ae7fdbc2f94475492ca4a.mockapi.io/pregnancy/v1';

  /// Récupère les données d'une semaine spécifique depuis l'API
  Future<WeekInfo?> fetchWeekInfo(int weekNumber) async {
    try {
      // Assurer que weekNumber >= 4
      final adjustedWeek = weekNumber < 4 ? 4 : weekNumber;

      final response = await http
          .get(
            Uri.parse('$_baseUrl/weekInfo?weekNumber=$adjustedWeek'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          return WeekInfo.fromJson(data.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des données de semaine: $e');
      return null;
    }
  }

  /// Récupère les données de plusieurs semaines
  Future<List<WeekInfo>> fetchMultipleWeeks(List<int> weekNumbers) async {
    final results = <WeekInfo>[];
    for (final week in weekNumbers) {
      final info = await fetchWeekInfo(week);
      if (info != null) {
        results.add(info);
      }
    }
    return results;
  }

  /// Construit le chemin local de l'image à partir du nom de fichier
  static String buildLocalImagePath(String imageUrl) {
    // imageUrl contient généralement juste le nom du fichier (ex: week4.png)
    if (imageUrl.isEmpty) return 'assets/imagesBaby/week4.png';

    // Si c'est déjà un chemin, le retourner tel quel
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    // Sinon, construire le chemin complet
    return 'assets/imagesBaby/$imageUrl';
  }
}
