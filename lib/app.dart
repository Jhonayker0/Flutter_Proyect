import 'package:flutter/material.dart';
import 'package:flutter_application/auth/presentation/bindings/auth_binding.dart';
import 'package:get/get.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AuthBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: Routes.login,
      getPages: Routes.pages,
    );
  }
}
