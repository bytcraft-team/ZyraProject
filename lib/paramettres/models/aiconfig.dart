class AiConfig {
  bool aiActif;
  bool cycle;
  bool grossesse;
  bool symptomes;
  bool suggestions;
  int niveau;

  AiConfig({
    required this.aiActif,
    required this.cycle,
    required this.grossesse,
    required this.symptomes,
    required this.suggestions,
    required this.niveau,
  });

  String buildSystemPrompt() {
    String base =
        "Tu es un assistant médical spécialisé dans le cycle et la grossesse.";

    if (niveau == 0) base += " Réponses très courtes.";
    if (niveau == 1) base += " Réponses normales.";
    if (niveau == 2) base += " Réponses détaillées.";

    if (!cycle) base += " Ignore cycle.";
    if (!grossesse) base += " Ignore grossesse.";
    if (!symptomes) base += " Ignore symptômes.";

    return base;
  }
}