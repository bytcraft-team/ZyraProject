import 'dart:convert';

class UserModel {
  final String firstName;
  final String? lastName;
  final String? profileImageUrl;
  final bool hasUnreadNotifications;
  final int unreadNotificationCount;

  const UserModel({
    required this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.hasUnreadNotifications = false,
    this.unreadNotificationCount = 0,
  });

  /// Génère les initiales de l'utilisateur (ex: "Jane Doe" -> "JD")
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last =
        lastName != null && lastName!.isNotEmpty ? lastName![0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : 'U';
  }

  /// Crée une copie de UserModel en modifiant uniquement les champs spécifiés
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    bool? hasUnreadNotifications,
    int? unreadNotificationCount,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      hasUnreadNotifications: hasUnreadNotifications ?? this.hasUnreadNotifications,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
    );
  }

  /// Convertit l'objet en Map pour la sérialisation (JSON / Base de données)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'hasUnreadNotifications': hasUnreadNotifications,
      'unreadNotificationCount': unreadNotificationCount,
    };
  }

  /// Crée une instance de UserModel à partir d'une Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      hasUnreadNotifications: map['hasUnreadNotifications'] as bool? ?? false,
      unreadNotificationCount: map['unreadNotificationCount'] as int? ?? 0,
    );
  }

  /// Encode le modèle en chaîne JSON
  String toJson() => jsonEncode(toMap());

  /// Décode une chaîne JSON pour créer un UserModel
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}