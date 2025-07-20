import 'package:get/get.dart';
import 'package:study_buddy/Routes/app_routes.dart';

class LoginsignupController extends GetxController {

    Future<void> signInWithGoogle() async {
      // Implement SignIn using Google
  }

  Future<void> signInWithFacebook() async {
    // Implement SignIn using Facebook
  }

  void login() {
    Get.toNamed(AppRoutes.loginScreen);
  }

  void signup() {
    Get.toNamed(AppRoutes.signupScreen);
  }
}
