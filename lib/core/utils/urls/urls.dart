class URls {
  static const String baseurl = "https://unfall-update.de/api/v1";
  static const String singupurl = "$baseurl/users/createUser";
  static const String loginurl = "$baseurl/auth/login";
  static const String forgetPassword = "$baseurl/auth/forgetPassword";
  static const String otpCrossCheck = "$baseurl/auth/otpCrossCheck";
  static const String changePassword = "$baseurl/auth/changePassword";
  static const String resetPassword = "$baseurl/auth/resetPassword";
  static const String reSendOTP = "$baseurl/auth/reSend_OTP";
  static const String notificationtoggle = "$baseurl/users/notification-toggle";

  static const String setFCMToken = "$baseurl/users/setFCMToken";
  static const String alluser = "$baseurl/users/getAlluser";
  static const String profileimage =
      "$baseurl/users/uploadOrChangeImg?acctionType=upload";
  static const String profileupdate = "$baseurl/users/updateProfileData";
  static const String selfDistuct = "$baseurl/users/selfDestruct";
  static const String suspendaccount = "$baseurl/users/block";
  static const String allcases = "$baseurl/cases/all-cases";
  static String getSingleCaseDetails(String id) => "$baseurl/cases/case/$id";
  static const String createCase = "$baseurl/cases/manageCase";
  static const String getProfile = "$baseurl/users/getProfile";
  static const String deletecase = "$baseurl/cases/manageCase/";
  static const String updateoverview = "$baseurl/cases/manageCase/";
  static const String connectionSoket = "ws://unfall-update.de/api/v1?token=";
  static const String senderurl =
      "https://unfall-update.de/api/v1/message/conversation/";
  static const String lastmessage = "$baseurl/message/chat-list";
  static const String getAllNotifications =
      "$baseurl/notifications/getAllNotifications";
  static String markNotificationRead(String id) =>
      "$baseurl/notifications/viewSpecificNotification?notification_id=$id";

  static String deleteUserNotification(String id) =>
      "$baseurl/notifications/deleteUserNotification/$id";

  static String markNotificationUnread(String id) =>
      "$baseurl/notifications/mark-as-unread/$id";

  static const String getNotificationForNotificationBell =
      "$baseurl/notifications/getNotificationForNotificationBell";
  static const String sentImage = "$baseurl/message/chat-file";
}
