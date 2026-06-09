class AppNotificationSettings {
  final bool regles;
  final bool fertile;
  final bool ovulation;
  final bool grossesse; 

  const AppNotificationSettings({
    this.regles = true,
    this.fertile = true,
    this.ovulation = true,
    this.grossesse = true, 
  });

  AppNotificationSettings copyWith({
    bool? regles,
    bool? fertile,
    bool? ovulation,
    bool? grossesse,
  }) {
    return AppNotificationSettings(
      regles: regles ?? this.regles,
      fertile: fertile ?? this.fertile,
      ovulation: ovulation ?? this.ovulation,
      grossesse: grossesse ?? this.grossesse, 
    );
  }

  Map<String, dynamic> toJson() => {
        'regles': regles,
        'fertile': fertile,
        'ovulation': ovulation,
        'grossesse': grossesse, 
      };

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AppNotificationSettings(
      regles: json['regles'] as bool? ?? true,
      fertile: json['fertile'] as bool? ?? true,
      ovulation: json['ovulation'] as bool? ?? true,
      grossesse: json['grossesse'] as bool? ?? true, 
    );
  }
}