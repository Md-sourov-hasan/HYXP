class ApiEndpoint {
  ApiEndpoint._();

  static const String baseUrl = 'http://187.77.182.87:9003/api';

  static const String login = '$baseUrl/auth/login/';
  static const String googleAuth = '$baseUrl/auth/google/';
  static const String logout = '$baseUrl/auth/logout/';
  static const String firebaseAuth = '$baseUrl/auth/firebase';
  static const String verifyToken = '$baseUrl/auth/verify-token';
  static const String sendOtp = '$baseUrl/auth/send_otp';
  static const String verifyOtp = '$baseUrl/auth/verify_otp';
  static const String verifyEmail = '$baseUrl/auth/verify-email/';
  static const String verifyResetOtp = '$baseUrl/auth/verify-reset-otp/';
  static const String signup = '$baseUrl/auth/signup/';
  static const String resetPassword = '$baseUrl/auth/reset-password/';
  static const String changePassword = '$baseUrl/auth/change-password/';
  static const String forgotPassword = '$baseUrl/auth/forgot-password/';
  static const String userPreference = '$baseUrl/user/preference/';
  static const String authUnits = '$baseUrl/auth/units/';
  static const String profile = '$baseUrl/auth/profile/';
  static const String currentUser = '$baseUrl/user/users/me';
  static String userById(String id) => '$baseUrl/user/users/$id';

  static String workouts({int? equipmentId, int offset = 0, int limit = 20}) {
    final queryParams = <String>[
      if (equipmentId != null && equipmentId > 0) 'equipment_id=$equipmentId',
      'offset=$offset',
      'limit=$limit',
    ];

    return '$baseUrl/equipments/workout/?${queryParams.join('&')}';
  }

  static String equipments({int offset = 0, int limit = 20}) =>
      '$baseUrl/equipments/equipments/?offset=$offset&limit=$limit';

  static String muscleGroups({int offset = 0, int limit = 20}) =>
      '$baseUrl/equipments/muscle-groups/?offset=$offset&limit=$limit';

  static String equipmentCategories({int offset = 0, int limit = 20}) =>
      '$baseUrl/equipments/categories/?offset=$offset&limit=$limit';

  static String workoutById(int id) => '$baseUrl/equipments/workout/$id';
  static String workoutStartLog(int id) =>
      '$baseUrl/equipments/workout/$id/start-log';
  static const String aiScanEquipmentUpload =
      '$baseUrl/ai/scan-equipment-upload';
  static const String aiVerifyEquipment = '$baseUrl/ai/verify-equipment';

  static String contents({
    bool isActive = true,
    String? feed,
    int offset = 0,
    int? limit,
  }) {
    final queryParams = <String>[
      'is_active=$isActive',
      if (feed != null && feed.trim().isNotEmpty) 'feed=$feed',
      'offset=$offset',
      if (limit != null) 'limit=$limit',
    ];

    return '$baseUrl/content/contents/?${queryParams.join('&')}';
  }

  static String contentById(int id) => '$baseUrl/content/contents/$id';
  static String contentStartLog(int id) =>
      '$baseUrl/content/contents/$id/start-log';

  static String contentBookmarks(int id) =>
      '$baseUrl/content/contents/$id/bookmarks';

  static String contentBookmarkCount(int id) =>
      '$baseUrl/content/contents/$id/bookmarks/count';

  static String equipmentById(int id) => '$baseUrl/equipments/equipments/$id';

  static String muscleGroupById(int id) =>
      '$baseUrl/equipments/muscle-groups/$id';

  static String equipmentCategoryById(int id) =>
      '$baseUrl/equipments/categories/$id';

  static const String sessions = '$baseUrl/sessions/sessions';
  static String activeSession() => '$sessions/active';
  static String sessionById(int id) => '$sessions/$id';
  static String completeSession(int id) => '$sessions/$id/complete';
  static String cardioLog() => '$baseUrl/sessions/cardio-log';
  static String completeSessionWorkout(int id) =>
      '$baseUrl/sessions/session-workouts/$id/complete';
  static String setLog() => '$baseUrl/sessions/set-log';

  static String sessionsList({
    required String userId,
    int offset = 0,
    int limit = 20,
  }) => '$sessions?user_id=$userId&offset=$offset&limit=$limit';

  static String progressSummary({String? startDate, String? endDate}) {
    final params = <String>[
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/sessions/progress/summary$query';
  }

  static String progressChart({String? startDate, String? endDate}) {
    final params = <String>[
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/sessions/progress/chart$query';
  }

  static String progressBests({
    int limit = 3,
    String? startDate,
    String? endDate,
  }) {
    final params = <String>[
      'limit=$limit',
      if (startDate != null) 'start_date=$startDate',
      if (endDate != null) 'end_date=$endDate',
    ];
    return '$baseUrl/sessions/progress/bests?${params.join('&')}';
  }

  static String progressHighlights({required String userId}) =>
      '$baseUrl/sessions/progress/highlights?user_id=${Uri.encodeQueryComponent(userId)}';

  static String progressRecentActivity({
    required String userId,
    int limit = 5,
  }) =>
      '$baseUrl/sessions/progress/recent-activity?user_id=${Uri.encodeQueryComponent(userId)}&limit=$limit';
}
