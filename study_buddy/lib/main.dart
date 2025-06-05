import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_buddy/Routes/app_pages.dart';
import 'package:study_buddy/Routes/app_routes.dart';
import 'package:study_buddy/Bindings/binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, __) {
        return GetMaterialApp(
          title: "Study Buddy",
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashScreen,
          getPages: AppPages.pages,
          initialBinding: Binding(),
        );
      },
    );
  }
}
