import 'package:get/get.dart';
import 'package:hawiisaac/features/authentication/view/auth_options_view.dart';
import 'package:hawiisaac/features/authentication/view/forgot_password_screen.dart';
import 'package:hawiisaac/features/authentication/view/login_screen.dart';
import 'package:hawiisaac/features/authentication/view/password_change_complete_screen.dart';
import 'package:hawiisaac/features/authentication/view/password_change_screen.dart';
import 'package:hawiisaac/features/authentication/view/selectunit_screen.dart';
import 'package:hawiisaac/features/authentication/view/sign_up_view.dart';
import 'package:hawiisaac/features/authentication/view/verification_screen.dart';
import 'package:hawiisaac/features/bottom_navigation/screens/bottom_navigation_screen.dart';
import 'package:hawiisaac/features/home/presentation/screens/content_details_screen.dart';
import 'package:hawiisaac/features/home/presentation/screens/home_screen.dart';
import 'package:hawiisaac/features/home/presentation/screens/warm_up_details_screen.dart';
import 'package:hawiisaac/features/home/screens/bookmarks_screen.dart';
import 'package:hawiisaac/features/home/screens/notifications_screen.dart';
import 'package:hawiisaac/features/loggin/presentation/screens/ai_exercise_session_screen.dart';
import 'package:hawiisaac/features/loggin/presentation/screens/loggin_screen.dart';
import 'package:hawiisaac/features/loggin/presentation/screens/main_loggin_screen.dart';
import 'package:hawiisaac/features/profile/screens/edit_profile_view.dart';
import 'package:hawiisaac/features/profile/screens/profile_view.dart';
import 'package:hawiisaac/features/progress/presentation/screens/progress_screen.dart';
import 'package:hawiisaac/features/scan/presentation/screens/equipment_view.dart';
import 'package:hawiisaac/features/scan/presentation/screens/exercise_detail_view.dart';
import 'package:hawiisaac/features/scan/presentation/screens/matched_equipment_view.dart';
import 'package:hawiisaac/features/splash_screen/view/splash_screen.dart';
import 'package:hawiisaac/features/profile/screens/privacy_policy_view.dart';
import 'package:hawiisaac/features/profile/screens/premium_view.dart';

class AppRoute {
  static String splashscreen = '/splashscreen';
  static String authOptionsScreen = '/authOptionsScreen';
  static String loginScreen = '/loginScreen';
  static String bottomNavigationScreen = '/bottomNavigationScreen';
  static String forgotPasswordScreen = '/forgotPasswordScreen';
  static String verificationScreen = '/verificationScreen';
  static String equipmentView = '/equipmentView';
  static String changepasswordScreen = '/changepasswordScreen';
  static String changepasswordCompleteScreen = '/changePasswordcompleteScreen';
  static String homeScreen = '/homeScreen';
  static String signupScreen = '/signupScreen';
  static String selectUnitsScreen = '/selectUnitsScreen';
  static String loggingScreen = '/loggingScreen';
  static String progressScreen = '/progressScreen';
  static String exeesiceDetailScreen = '/exerciseDetailScreen';
  static String machedEquipmentScreen = '/matchedEquipmentScreen';
  static String profileScreen = '/profileScreen';
  static String editProfileScreen = '/editProfileScreen';
  static String privacyPolicyScreen = '/privacyPolicyScreen';
  static String premiumScreen = '/premiumScreen';
  static String warmUpDetailsScreen = '/warmUpDetailsScreen';
  static String contentDetailsScreen = '/contentDetailsScreen';
  static String aiExerciseSessionScreen = '/aiExerciseSessionScreen';
  static String mainLogginScreen = '/mainLogginScreen';
  static String notificationsScreen = '/notificationsScreen';
  static String bookmarksScreen = '/bookmarksScreen';

  static String getSplashscreen() => splashscreen;
  static String getMainLogginScreen() => mainLogginScreen;
  static String getLoginScreen() => loginScreen;
  static String getEquipmentView() => equipmentView;
  static String getAuthOptionsScreen() => authOptionsScreen;
  static String getBottomNavigationScreen() => bottomNavigationScreen;
  static String getExeesiceDetailScreen() => exeesiceDetailScreen;
  static String getMatchedEquipmentScreen() => machedEquipmentScreen;
  static String getForgotPasswordScreen() => forgotPasswordScreen;
  static String getVerificationScreen() => verificationScreen;
  static String getChangepasswordScreen() => changepasswordScreen;
  static String getLoggingScreen() => loggingScreen;
  static String getChangepasswordCompleteScreen() =>
      changepasswordCompleteScreen;
  static String getHomeScreen() => homeScreen;
  static String getSignupScreen() => signupScreen;
  static String getSelectUnitsScreen() => selectUnitsScreen;
  static String getProgressScreen() => progressScreen;
  static String getProfileScreen() => profileScreen;
  static String getEditProfileScreen() => editProfileScreen;
  static String getPrivacyPolicyScreen() => privacyPolicyScreen;
  static String getPremiumScreen() => premiumScreen;
  static String getWarmUpDetailsScreen() => warmUpDetailsScreen;
  static String getContentDetailsScreen() => contentDetailsScreen;
  static String getAiExerciseSessionScreen() => aiExerciseSessionScreen;
  static String getNotificationsScreen() => notificationsScreen;
  static String getBookmarksScreen() => bookmarksScreen;

  static List<GetPage> routes = [
    GetPage(name: splashscreen, page: () => SplashScreen()),
    GetPage(name: authOptionsScreen, page: () => AuthOptionsView()),
    GetPage(name: equipmentView, page: () => EquipmentView()),
    GetPage(name: loginScreen, page: () => LoginView()),
    GetPage(name: bottomNavigationScreen, page: () => BottomNavigationScreen()),
    GetPage(name: forgotPasswordScreen, page: () => ForgetPasswordView()),
    GetPage(name: verificationScreen, page: () => VerificationView()),
    GetPage(name: changepasswordScreen, page: () => ChangePasswordView()),
    GetPage(
      name: changepasswordCompleteScreen,
      page: () => PasswordChangeCompleteScreen(),
    ),
    GetPage(name: homeScreen, page: () => HomeView()),
    GetPage(name: signupScreen, page: () => SignUpView()),
    GetPage(name: selectUnitsScreen, page: () => SelectUnitsView()),
    GetPage(name: machedEquipmentScreen, page: () => MatchedEquipmentView()),
    GetPage(name: loggingScreen, page: () => LoggingView()),
    GetPage(name: progressScreen, page: () => ProgressView()),
    GetPage(name: exeesiceDetailScreen, page: () => ExerciseDetailView()),
    GetPage(name: profileScreen, page: () => ProfileView()),
    GetPage(name: editProfileScreen, page: () => EditProfileView()),
    GetPage(name: privacyPolicyScreen, page: () => const PrivacyPolicyView()),
    GetPage(name: premiumScreen, page: () => const PremiumView()),
    GetPage(name: warmUpDetailsScreen, page: () => const WarmUpDetailsScreen()),
    GetPage(name: mainLogginScreen, page: () => const MainLogginScreen()),
    GetPage(name: bookmarksScreen, page: () => const BookmarksScreen()),
    GetPage(
      name: notificationsScreen,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: contentDetailsScreen,
      page: () => const ContentDetailsScreen(),
    ),
    GetPage(
      name: aiExerciseSessionScreen,
      page: () => const AiExerciseSessionScreen(),
    ),
  ];
}
