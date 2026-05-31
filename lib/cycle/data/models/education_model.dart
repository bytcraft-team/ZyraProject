
import 'cycle_model.dart';

// ─── Symptôme éducatif ────────────────────────────────────────
class EducationSymptom {
  final String label;
  final String emoji;
  final String explanation;

  const EducationSymptom({
    required this.label,
    required this.emoji,
    required this.explanation,
  });
}

// ─── Conseil pratique ─────────────────────────────────────────
class PracticalTip {
  final String emoji;
  final String category;
  final String tip;

  const PracticalTip({
    required this.emoji,
    required this.category,
    required this.tip,
  });
}

// ─── Alerte médicale ──────────────────────────────────────────
class MedicalAlert {
  final String title;
  final String description;
  final List<String> warningSignals;
  final String possibleCondition;

  const MedicalAlert({
    required this.title,
    required this.description,
    required this.warningSignals,
    required this.possibleCondition,
  });
}

// ─── Contenu éducatif complet par phase ───────────────────────
class PhaseEducationContent {
  final CyclePhase phase;
  final String illustrationAsset; // chemin SVG/image
  final String durationLabel;     // "3 à 7 jours"
  final String whatHappensTitle;
  final List<String> whatHappensParagraphs;
  final List<EducationSymptom> symptoms;
  final List<PracticalTip> tips;
  final MedicalAlert medicalAlert;

  const PhaseEducationContent({
    required this.phase,
    required this.illustrationAsset,
    required this.durationLabel,
    required this.whatHappensTitle,
    required this.whatHappensParagraphs,
    required this.symptoms,
    required this.tips,
    required this.medicalAlert,
  });

  // ── Données complètes par phase ────────────────────────────
  static PhaseEducationContent forPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.rules:
        return _rulesContent();
      case CyclePhase.fertile:
        return _fertileContent();
      case CyclePhase.ovulation:
        return _ovulationContent();
      case CyclePhase.luteal:
        return _lutealContent();
    }
  }

  // ── Phase Règles ───────────────────────────────────────────
  static PhaseEducationContent _rulesContent() {
    return const PhaseEducationContent(
      phase: CyclePhase.rules,
      illustrationAsset: 'assets/images/phase_rules.png',
      durationLabel: '3 à 7 jours',
      whatHappensTitle: 'Que se passe-t-il pendant les règles ?',
      whatHappensParagraphs: [
        'Quand la fécondation n\'a pas eu lieu, les niveaux '
            'd\'œstrogènes et de progestérone chutent brusquement. '
            'Cette baisse hormonale déclenche la desquamation de '
            'l\'endomètre — la muqueuse utérine — qui est évacuée '
            'par le vagin sous forme de saignements.',
        'Simultanément, ton cerveau envoie des signaux hormonaux '
            '(FSH — Hormone Folliculo-Stimulante) pour préparer '
            'les follicules ovariens du prochain cycle. C\'est un '
            'processus de renouvellement naturel et puissant.',
        'Les prostaglandines, des substances chimiques libérées '
            'par l\'utérus pour faciliter l\'expulsion, peuvent '
            'provoquer des contractions musculaires responsables '
            'des crampes menstruelles.',
      ],
      symptoms: [
        EducationSymptom(
          label: 'Crampes',
          emoji: '🤕',
          explanation:
              'Causées par les prostaglandines qui font contracter '
              'l\'utérus. Normales si modérées.',
        ),
        EducationSymptom(
          label: 'Fatigue',
          emoji: '😴',
          explanation:
              'La perte de sang et la baisse hormonale réduisent '
              'l\'énergie disponible.',
        ),
        EducationSymptom(
          label: 'Maux de tête',
          emoji: '🤯',
          explanation:
              'La chute des œstrogènes peut déclencher des '
              'migraines menstruelles.',
        ),
        EducationSymptom(
          label: 'Ballonnements',
          emoji: '🫃',
          explanation:
              'Les prostaglandines agissent aussi sur les intestins '
              'et peuvent causer des ballonnements.',
        ),
        EducationSymptom(
          label: 'Seins sensibles',
          emoji: '💗',
          explanation:
              'La sensibilité mammaire diminue en début de règles '
              'avec la chute de progestérone.',
        ),
        EducationSymptom(
          label: 'Humeur basse',
          emoji: '😢',
          explanation:
              'La sérotonine (hormone du bonheur) est influencée '
              'par les œstrogènes qui sont bas.',
        ),
      ],
      tips: [
        PracticalTip(
          emoji: '🌡️',
          category: 'Confort',
          tip: 'Bouillotte sur le bas-ventre — la chaleur détend '
              'les muscles utérins et soulage les crampes.',
        ),
        PracticalTip(
          emoji: '🍫',
          category: 'Alimentation',
          tip: 'Magnésium (chocolat noir, noix) pour réduire les '
              'crampes et améliorer l\'humeur.',
        ),
        PracticalTip(
          emoji: '💧',
          category: 'Hydratation',
          tip: 'Boire au moins 2L d\'eau par jour pour compenser '
              'les pertes et réduire les maux de tête.',
        ),
        PracticalTip(
          emoji: '🧘',
          category: 'Mouvement',
          tip: 'Yoga doux, étirements ou marche légère — éviter '
              'le sport intense les premiers jours.',
        ),
        PracticalTip(
          emoji: '😴',
          category: 'Sommeil',
          tip: 'Privilégier 8 à 9h de sommeil. Ton corps se '
              'régénère et reconstitue ses réserves de fer.',
        ),
        PracticalTip(
          emoji: '🛁',
          category: 'Soins',
          tip: 'Bains chauds relaxants avec du sel d\'Epsom pour '
              'détendre les muscles et apaiser les douleurs.',
        ),
      ],
      medicalAlert: MedicalAlert(
        title: 'Quand consulter un médecin ?',
        description:
            'Des règles douloureuses peuvent être normales, '
            'mais certains signes méritent une consultation.',
        warningSignals: [
          '🔴 Douleurs si intenses qu\'elles t\'empêchent '
              'de fonctionner normalement',
          '🔴 Saignements très abondants (changer de '
              'protection toutes les heures)',
          '🔴 Règles qui durent plus de 8 jours',
          '🔴 Absence de règles depuis plus de 3 mois',
          '🔴 Douleurs pendant les rapports sexuels',
        ],
        possibleCondition:
            '⚠️ Ces symptômes peuvent indiquer une endométriose, '
            'des fibromes utérins ou un déséquilibre hormonal. '
            'Un gynécologue peut établir un diagnostic précis.',
      ),
    );
  }

  // ── Phase Fertile ──────────────────────────────────────────
  static PhaseEducationContent _fertileContent() {
    return const PhaseEducationContent(
      phase: CyclePhase.fertile,
      illustrationAsset: 'assets/images/phase_fertile.png',
      durationLabel: '4 à 6 jours',
      whatHappensTitle: 'La fenêtre fertile : ton pic d\'énergie',
      whatHappensParagraphs: [
        'Après les règles, les follicules ovariens se développent '
            'sous l\'action de la FSH. L\'un d\'eux devient dominant '
            'et produit des quantités croissantes d\'œstrogènes.',
        'Cette montée en œstrogènes transforme littéralement ton '
            'corps et ton esprit : énergie décuplée, peau lumineuse, '
            'confiance en soi accrue, et libido augmentée. C\'est '
            'le moment où tu rayonnes naturellement.',
        'La glaire cervicale devient transparente et filante '
            '(comme du blanc d\'œuf), ce qui facilite la survie '
            'et le transport des spermatozoïdes vers l\'ovule. '
            'Les spermatozoïdes peuvent survivre jusqu\'à 5 jours '
            'dans cet environnement favorable.',
      ],
      symptoms: [
        EducationSymptom(
          label: 'Énergie haute',
          emoji: '⚡',
          explanation:
              'Les œstrogènes stimulent la production d\'énergie '
              'et améliorent l\'endurance physique.',
        ),
        EducationSymptom(
          label: 'Peau lumineuse',
          emoji: '✨',
          explanation:
              'Les œstrogènes stimulent la production de collagène '
              'et donnent un teint radieux.',
        ),
        EducationSymptom(
          label: 'Libido accrue',
          emoji: '💕',
          explanation:
              'Nature bien faite : le désir augmente naturellement '
              'pendant la fenêtre de fertilité.',
        ),
        EducationSymptom(
          label: 'Glaire cervicale',
          emoji: '💧',
          explanation:
              'Elle devient abondante, transparente et filante — '
              'signe visible de la fenêtre fertile.',
        ),
        EducationSymptom(
          label: 'Sociabilité',
          emoji: '🗣️',
          explanation:
              'Les œstrogènes améliorent les capacités de '
              'communication et de connexion sociale.',
        ),
        EducationSymptom(
          label: 'Créativité',
          emoji: '🎨',
          explanation:
              'Le cerveau est particulièrement actif et créatif '
              'sous l\'influence des œstrogènes.',
        ),
      ],
      tips: [
        PracticalTip(
          emoji: '🏃',
          category: 'Sport',
          tip: 'Profite de ton énergie maximale pour les entraînements '
              'intenses, HIIT ou musculation.',
        ),
        PracticalTip(
          emoji: '🥗',
          category: 'Alimentation',
          tip: 'Aliments riches en folates : épinards, lentilles, '
              'avocat — essentiels pour la santé reproductive.',
        ),
        PracticalTip(
          emoji: '💼',
          category: 'Productivité',
          tip: 'Planifie tes présentations importantes, entretiens '
              'et réunions pendant cette phase.',
        ),
        PracticalTip(
          emoji: '🌸',
          category: 'Bien-être',
          tip: 'Observe ta glaire cervicale chaque matin pour '
              'identifier précisément ta fenêtre fertile.',
        ),
        PracticalTip(
          emoji: '💑',
          category: 'Intime',
          tip: 'Si tu souhaites concevoir, c\'est le moment optimal. '
              'Si non, pense à la contraception.',
        ),
        PracticalTip(
          emoji: '🎯',
          category: 'Focus',
          tip: 'Tes capacités cognitives sont à leur maximum. '
              'Idéal pour apprendre quelque chose de nouveau.',
        ),
      ],
      medicalAlert: MedicalAlert(
        title: 'Points de vigilance',
        description:
            'La phase fertile est naturelle, mais certains signes '
            'peuvent indiquer un problème d\'ovulation.',
        warningSignals: [
          '🔴 Absence de glaire cervicale sur plusieurs cycles',
          '🔴 Cycles très courts (moins de 21 jours)',
          '🔴 Tentatives de conception sans succès '
              'après 12 mois',
          '🔴 Douleurs pelviennes récurrentes',
          '🔴 Antécédents d\'infections pelviennes',
        ],
        possibleCondition:
            '⚠️ Un trouble de l\'ovulation (SOPK, insuffisance '
            'ovarienne) peut affecter la fertilité. '
            'Un bilan hormonal permet d\'évaluer la situation.',
      ),
    );
  }

  // ── Phase Ovulation ────────────────────────────────────────
  static PhaseEducationContent _ovulationContent() {
    return const PhaseEducationContent(
      phase: CyclePhase.ovulation,
      illustrationAsset: 'assets/images/phase_ovulation.png',
      durationLabel: '1 à 2 jours',
      whatHappensTitle: 'L\'ovulation : le moment clé du cycle',
      whatHappensParagraphs: [
        'Un pic soudain de LH (Hormone Lutéinisante) déclenche '
            'la rupture du follicule dominant. L\'ovule est libéré '
            'et capturé par la trompe de Fallope. Il reste viable '
            'seulement 12 à 24 heures.',
        'La température corporelle basale augmente légèrement '
            '(0.2 à 0.5°C) juste après l\'ovulation sous l\'effet '
            'de la progestérone. C\'est un indicateur rétroactif '
            'utilisé dans la méthode sympto-thermique.',
        'Certaines femmes ressentent un léger pincement ou une '
            'douleur d\'un côté du bas-ventre appelé Mittelschmerz '
            '(douleur du milieu en allemand), causé par la rupture '
            'du follicule ou l\'irritation du péritoine.',
      ],
      symptoms: [
        EducationSymptom(
          label: 'Mittelschmerz',
          emoji: '📍',
          explanation:
              'Légère douleur d\'un côté du bassin due à la '
              'rupture folliculaire. Normale et passagère.',
        ),
        EducationSymptom(
          label: 'Temp. élevée',
          emoji: '🌡️',
          explanation:
              'Hausse de 0.2 à 0.5°C après l\'ovulation. '
              'Mesurer chaque matin avant de se lever.',
        ),
        EducationSymptom(
          label: 'Glaire filante',
          emoji: '🥚',
          explanation:
              'Maximum de glaire transparente et très élastique, '
              'comme du blanc d\'œuf cru.',
        ),
        EducationSymptom(
          label: 'Libido max',
          emoji: '💖',
          explanation:
              'Le pic de LH et d\'œstrogènes atteint son maximum, '
              'stimulant fortement le désir.',
        ),
        EducationSymptom(
          label: 'Légère tache',
          emoji: '🔴',
          explanation:
              'Spotting ovulatoire : quelques gouttes de sang '
              'lors de la rupture folliculaire.',
        ),
        EducationSymptom(
          label: 'Col ouvert',
          emoji: '⭕',
          explanation:
              'Le col de l\'utérus est haut, mou et ouvert '
              'pour faciliter le passage des spermatozoïdes.',
        ),
      ],
      tips: [
        PracticalTip(
          emoji: '🌡️',
          category: 'Mesure',
          tip: 'Mesure ta température basale chaque matin avant '
              'de te lever, même heure, même thermomètre.',
        ),
        PracticalTip(
          emoji: '📅',
          category: 'Tracking',
          tip: 'Note le jour exact dans ton journal — '
              'cela améliore la précision des prédictions futures.',
        ),
        PracticalTip(
          emoji: '🥗',
          category: 'Alimentation',
          tip: 'Zinc (graines de courge, viande) pour soutenir '
              'la santé reproductive et l\'ovulation.',
        ),
        PracticalTip(
          emoji: '🧘',
          category: 'Stress',
          tip: 'Le stress chronique peut perturber ou retarder '
              'l\'ovulation. Méditation recommandée.',
        ),
        PracticalTip(
          emoji: '💤',
          category: 'Sommeil',
          tip: 'Un sommeil de qualité régule les hormones '
              'nécessaires à une ovulation normale.',
        ),
        PracticalTip(
          emoji: '🔬',
          category: 'Test',
          tip: 'Les tests d\'ovulation urinaires détectent '
              'le pic de LH 24h avant l\'ovulation.',
        ),
      ],
      medicalAlert: MedicalAlert(
        title: 'Signes d\'une ovulation absente',
        description:
            'L\'anovulation (absence d\'ovulation) peut passer '
            'inaperçue car les règles restent présentes.',
        warningSignals: [
          '🔴 Température basale sans hausse notable',
          '🔴 Cycles très irréguliers (variation > 7 jours)',
          '🔴 Absence de glaire cervicale fertile',
          '🔴 Tests d\'ovulation négatifs sur 3+ cycles',
          '🔴 Acné sévère, pilosité excessive, prise de poids',
        ],
        possibleCondition:
            '⚠️ Le syndrome des ovaires polykystiques (SOPK) '
            'est la cause principale d\'anovulation. '
            'Un dosage hormonal (LH, FSH, AMH) permet '
            'de poser le diagnostic.',
      ),
    );
  }

  // ── Phase Lutéale ──────────────────────────────────────────
  static PhaseEducationContent _lutealContent() {
    return const PhaseEducationContent(
      phase: CyclePhase.luteal,
      illustrationAsset: 'assets/images/phase_luteal.png',
      durationLabel: '10 à 16 jours',
      whatHappensTitle: 'La phase lutéale : préparation et repos',
      whatHappensParagraphs: [
        'Après l\'ovulation, le follicule vide se transforme en '
            'corps jaune (corpus luteum) qui sécrète de la '
            'progestérone. Cette hormone prépare l\'endomètre '
            'à accueillir un embryon en l\'épaississant.',
        'Si la fécondation n\'a pas eu lieu, le corps jaune '
            'dégénère après 10 à 14 jours, provoquant la chute '
            'de progestérone et d\'œstrogènes qui déclenche '
            'les règles suivantes.',
        'C\'est pendant cette phase que le SPM (Syndrome '
            'Prémenstruel) peut apparaître dans les 7 à 10 jours '
            'avant les règles : ballonnements, irritabilité, '
            'envies alimentaires et sensibilité émotionnelle '
            'sont tous liés aux fluctuations hormonales.',
      ],
      symptoms: [
        EducationSymptom(
          label: 'SPM',
          emoji: '😤',
          explanation:
              'Le syndrome prémenstruel touche 75% des femmes. '
              'Irritabilité, larmes, anxiété — tout est hormonal.',
        ),
        EducationSymptom(
          label: 'Ballonnements',
          emoji: '🫃',
          explanation:
              'La progestérone ralentit le transit intestinal '
              'et favorise la rétention d\'eau.',
        ),
        EducationSymptom(
          label: 'Seins lourds',
          emoji: '💗',
          explanation:
              'La progestérone stimule les glandes mammaires, '
              'causant tension et sensibilité.',
        ),
        EducationSymptom(
          label: 'Fatigue',
          emoji: '😴',
          explanation:
              'La progestérone a un effet sédatif naturel. '
              'Un besoin de repos accru est normal.',
        ),
        EducationSymptom(
          label: 'Envies sucrées',
          emoji: '🍫',
          explanation:
              'La chute de sérotonine pousse à chercher du '
              'sucre pour compenser. Résiste avec du magnésium.',
        ),
        EducationSymptom(
          label: 'Insomnie',
          emoji: '🌙',
          explanation:
              'En fin de phase, la progestérone baisse et '
              'peut perturber la qualité du sommeil.',
        ),
      ],
      tips: [
        PracticalTip(
          emoji: '🥦',
          category: 'Alimentation',
          tip: 'Crucifères (brocoli, chou) pour éliminer '
              'l\'excès d\'œstrogènes et réduire le SPM.',
        ),
        PracticalTip(
          emoji: '🍌',
          category: 'Nutriments',
          tip: 'Vitamine B6 (banane, poulet) contre '
              'l\'irritabilité et les sautes d\'humeur.',
        ),
        PracticalTip(
          emoji: '☕',
          category: 'À éviter',
          tip: 'Réduire caféine, alcool et sel qui aggravent '
              'les ballonnements et l\'irritabilité.',
        ),
        PracticalTip(
          emoji: '🧘',
          category: 'Stress',
          tip: 'Méditation, respiration profonde, yoga '
              'restauratif pour gérer l\'anxiété prémenstruelle.',
        ),
        PracticalTip(
          emoji: '🛁',
          category: 'Confort',
          tip: 'Bains chauds avec huiles essentielles de '
              'lavande pour détente et meilleur sommeil.',
        ),
        PracticalTip(
          emoji: '📔',
          category: 'Émotions',
          tip: 'Journaling émotionnel : écrire ce que tu '
              'ressens aide à distinguer émotions réelles et SPM.',
        ),
      ],
      medicalAlert: MedicalAlert(
        title: 'SPM sévère & TDPM',
        description:
            'Le Trouble Dysphorique Prémenstruel (TDPM) est '
            'une forme sévère de SPM qui impacte '
            'significativement la qualité de vie.',
        warningSignals: [
          '🔴 Dépression ou anxiété sévère avant les règles',
          '🔴 Crises de larmes incontrôlables',
          '🔴 Pensées négatives intenses ou suicidaires',
          '🔴 Incapacité à travailler ou relations détruites',
          '🔴 Symptômes disparaissant dès les règles',
        ],
        possibleCondition:
            '⚠️ Le TDPM est une condition médicale reconnue '
            'qui nécessite une prise en charge. Des traitements '
            'efficaces existent (ISRS, contraception hormonale). '
            'Ne reste pas seule avec ces symptômes.',
      ),
    );
  }
}