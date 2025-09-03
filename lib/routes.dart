import 'package:flutter_application/presentation/bindings/auth_binding.dart';
import 'package:flutter_application/presentation/bindings/categories_binding.dart';
import 'package:flutter_application/presentation/bindings/create_activity_binding.dart';
import 'package:flutter_application/presentation/bindings/create_category_binding.dart';
import 'package:flutter_application/presentation/bindings/create_course_binding.dart';
import 'package:flutter_application/presentation/bindings/edit_category_binding.dart';
import 'package:flutter_application/presentation/bindings/home_binding.dart';
import 'package:flutter_application/presentation/bindings/main_navigation_binding.dart';
import 'package:flutter_application/presentation/bindings/settings_binding.dart';
import 'package:flutter_application/presentation/pages/categories_page.dart';
import 'package:flutter_application/presentation/pages/create_activity_page.dart';
import 'package:flutter_application/presentation/pages/create_category_page.dart';
import 'package:flutter_application/presentation/pages/create_course.dart';
import 'package:flutter_application/presentation/pages/edit_category_page.dart';
import 'package:flutter_application/presentation/pages/login_page.dart';
import 'package:flutter_application/presentation/pages/main_page.dart';
import 'package:get/get.dart';
import 'package:flutter_application/presentation/pages/sign_up_page.dart';
import 'package:flutter_application/presentation/bindings/sign_up_binding.dart';

import 'package:flutter_application/presentation/bindings/course_detail_binding.dart';
import 'package:flutter_application/presentation/pages/course_detail_page.dart';

import 'presentation/pages/settings_page.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String main = '/main';
  static const String settings = '/settings';
  static const String createActivity = '/create-activity';
  static const String createCategory = '/create-category';
  static const String createCourse = '/create-course';
  static const String categories = '/categories';
  static const String editCategory = '/edit-category';
  static const String courseDetail = '/course-detail';

  static List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: signup,
      page: () =>  SignUpPage(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: home,
      page: () => const MainPage(),
      bindings: [
        HomeBinding(),
        MainNavigationBinding(),
        SettingsBinding(),
      ],
    ),
    GetPage(
      name: createActivity,
      page: () => CreateActivityPage(),
      binding: CreateActivityBinding(),
    ),
    GetPage(
      name: createCategory,
      page: () => CreateCategoryPage(),
      binding: CreateCategoryBinding(),
    ),
    GetPage(
      name: createCourse,
      page: () => CreateCoursePage(),
      binding: CreateCourseBinding(),
    ),
    /*GetPage(
      name: categories,
      page: () => const CategoriesPage(),
      binding: CategoriesBinding(),
    ),*/
    GetPage(
      name: categories,
      page: () => const CategoriesPage(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: '$editCategory/:id',
      page: () => EditCategoryPage(),
      binding: EditCategoryBinding(),
    ),
    GetPage(
      name: settings,
      page: () => SettingsPage(),
      binding: SettingsBinding()
    ),
    GetPage(
      name: courseDetail,
      page: () => const CourseDetailPage(),
      binding: CourseDetailBinding(),
    ),
  ];
}
