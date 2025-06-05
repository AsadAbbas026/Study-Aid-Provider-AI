import 'package:get/get.dart';
import 'package:study_buddy/Routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginsignupController extends GetxController {

    Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        // User is signed in successfully
        print('User signed in: ${userCredential.user?.email}');
        Get.toNamed(AppRoutes.dashboardScreen);
      } else {
        // Sign-in failed
        print('Sign-in failed');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
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
