import 'user_answers_model.dart';

class UserDataModel {
  final UserAnswersModel? answers;
  final int currentWeek;
  final String pregnancyStatus;

  UserDataModel({
    required this.answers,
    required this.currentWeek,
    required this.pregnancyStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': answers?.toJson(),
      'currentWeek': currentWeek,
      'pregnancyStatus': pregnancyStatus,
    };
  }

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    final answersJson = json['answers'] as Map<String, dynamic>?;
    return UserDataModel(
      answers: answersJson != null ? UserAnswersModel.fromJson(answersJson) : null,
      currentWeek: json['currentWeek'] as int? ?? 0,
      pregnancyStatus: json['pregnancyStatus'] as String? ?? 'unknown',
    );
  }
}
