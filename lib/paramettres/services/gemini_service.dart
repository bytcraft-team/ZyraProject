import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:zyra/paramettres/models/aiconfig.dart';

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<String> askGemini({
    required String message,
    required AiConfig config,
  }) async {
    if (!config.aiActif) {
      return "🤖 Assistant IA désactivé";
    }

    try {
      // 🟢 حطي الساروت الكامل ديالك هنا لّي كيبدا بـ AQ
      final String keyDeTest = "AQ.Ab8RN6I3MeEfnTdkKmgesew_BvgepzN-PDVGlA8aaZTroTtkFQ";

      // 🛠️ التجهيز الرسمي للموديل gemini-2.0-flash المجاني
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: keyDeTest,
      );

      final prompt = _buildPrompt(message, config);
      final content = [Content.text(prompt)];
      
      // إرسال الطلب بطريقة غوغل الرسمية الآمنة
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      }
      return "Pas de réponse textuelle de Gemini";
    } catch (e) {
      return "Erreur Gemini: $e";
    }
  }

  String _buildPrompt(String message, AiConfig config) {
    String prompt = "Tu es un assistant médical spécialisé dans le cycle menstruel et la grossesse. Réponds de manière simple, claire et sécurisée.";

    if (config.niveau == 0) {
      prompt += " Réponses très courtes.";
    } else if (config.niveau == 1) {
      prompt += " Réponses équilibrées.";
    } else {
      prompt += " Réponses détaillées avec explications.";
    }

    prompt += "\n\nUtilisateur: $message";
    return prompt;
  }
}