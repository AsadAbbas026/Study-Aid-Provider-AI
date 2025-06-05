import 'package:get/get.dart';
import 'package:study_buddy/Routes/app_routes.dart';
import 'package:study_buddy/Views/Dashboard/dashboard_screen.dart';
import 'package:study_buddy/Views/Login/login_screen.dart';
import 'package:study_buddy/Views/Settings/general_settings_screen.dart';
import 'package:study_buddy/Views/Settings/profile_settings_screen.dart';
import 'package:study_buddy/Views/LoginSignup/loginSignup_screen.dart';
import 'package:study_buddy/Views/SignUp/signup_screen.dart';
import 'package:study_buddy/Views/Splash/splash.dart';
import 'package:study_buddy/Views/Notes/notes_screen.dart';
import 'package:study_buddy/Views/Summaries/summaries_screen.dart';
import 'package:study_buddy/Views/Reminders/reminders_screen.dart';
import 'package:study_buddy/Views/Quiz/quiz_screen.dart';
import 'package:study_buddy/Views/Quiz/start_quiz.dart';
import 'package:study_buddy/Views/Quiz/quiz_result.dart';
import 'package:study_buddy/Views/Study Schedule/study_schedule.dart';
import 'package:study_buddy/Views/Goals/goals_screen.dart';
import 'package:study_buddy/Views/Progress Overview/progress_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.signupScreen,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: AppRoutes.loginSignupScreen,
      page: () => LoginSignupScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboardScreen,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.generalsettingsScreen,
      page: () => GeneralSettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.profilesettingsScreen,
      page: () => UserProfileScreen(userId: '',),
    ),
    GetPage(
      name: AppRoutes.notesScreen,
      page: () => NotesScreen(),
    ),
    GetPage(
      name: AppRoutes.summariesScreen,
      page: () => SummariesScreen(),
    ),
    GetPage(
      name: AppRoutes.reminderScreen,
      page: () => RemindersScreen(),
    ),
    GetPage(name: AppRoutes.studySchedule, page: () => StudySchedule()),
    GetPage(
      name: AppRoutes.quizScreen,
      page: () => QuizScreen()),
    GetPage(
      name: AppRoutes.startQuiz,
      page: () => StartQuizScreen(userId: 'ABC', quizTitle: 'XYZ', quizId: 0,),
    ),
    GetPage(name: AppRoutes.quizResult, page: () => QuizResult(results: [])),
    GetPage(name: AppRoutes.goals, page: () => Goals()),
    GetPage(
      name: AppRoutes.progressOverview,
      page: () => ProgressScreen(),
    ),
  ];
}
