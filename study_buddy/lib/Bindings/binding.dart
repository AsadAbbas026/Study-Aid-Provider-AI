import 'package:get/get.dart';

import 'package:study_buddy/Controller/login_controller.dart';
import 'package:study_buddy/Controller/signup_controller.dart';
import 'package:study_buddy/Controller/opt_controller.dart';
import 'package:study_buddy/Controller/loginSignup_controller.dart';
import 'package:study_buddy/Controller/notes_controller.dart';
import 'package:study_buddy/Controller/reminder_controller.dart';
import 'package:study_buddy/Controller/summaries_controller.dart';
import 'package:study_buddy/Controller/quiz_controller.dart';
import 'package:study_buddy/Controller/schedule_controller.dart';
import 'package:study_buddy/Controller/goal_controller.dart';
import 'package:study_buddy/Controller/side_menu_controller.dart';
import 'package:study_buddy/Controller/user_profile_controller.dart';


class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    Get.lazyPut(() => OTPController(), fenix: true);
    Get.lazyPut(() => LoginsignupController(), fenix: true);
    Get.lazyPut(() => NotesController(), fenix: true);
    Get.lazyPut(() => RemindersController(), fenix: true);
    Get.lazyPut(() => SummariesController(), fenix: true);
    Get.lazyPut(() => QuizController(), fenix: true);
    Get.lazyPut(() => ScheduleController(), fenix: true);
    Get.lazyPut(() => GoalController(), fenix: true);
    Get.put(SideMenuController(), permanent: true);
    Get.put(UserProfileController(), permanent: true);
  }
}
