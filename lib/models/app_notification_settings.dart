class AppNotificationSettings {
  final bool regles;
  final bool fertile;
  final bool ovulation;

  const AppNotificationSettings({
    this.regles = true,
    this.fertile = true,
    this.ovulation = true,
  });

  AppNotificationSettings copyWith({
    bool? regles,
    bool? fertile,
    bool? ovulation,
  }) {
    return AppNotificationSettings(
      regles: regles ?? this.regles,
      fertile: fertile ?? this.fertile,
      ovulation: ovulation ?? this.ovulation,
    );
  }
}