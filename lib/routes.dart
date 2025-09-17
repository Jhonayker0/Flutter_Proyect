// Auth imports
import 'package:flutter_application/auth/presentation/bindings/auth_binding.dart';
import 'package:flutter_application/auth/presentation/bindings/sign_up_binding.dart';
import 'package:flutter_application/auth/presentation/pages/login_page.dart';
import 'package:flutter_application/auth/presentation/pages/sign_up_page.dart';

// Categories imports
import 'package:flutter_application/categories/presentation/bindings/categories_binding.dart';
import 'package:flutter_application/categories/presentation/bindings/view_categories_binding.dart'
    as view_cat;
import 'package:flutter_application/categories/presentation/bindings/create_category_binding.dart';
import 'package:flutter_application/categories/presentation/bindings/edit_category_binding.dart';
import 'package:flutter_application/categories/presentation/pages/categories_page.dart';
import 'package:flutter_application/categories/presentation/pages/create_category_page.dart';
import 'package:flutter_application/categories/presentation/pages/edit_category_page.dart';

// Activities imports
import 'package:flutter_application/activities/presentation/bindings/create_activity_binding.dart';
import 'package:flutter_application/activities/presentation/pages/create_activity_page.dart';

// Courses imports
import 'package:flutter_application/courses/presentation/bindings/create_course_binding.dart';
import 'package:flutter_application/courses/presentation/bindings/course_detail_binding.dart';
import 'package:flutter_application/courses/presentation/bindings/join_course_binding.dart';
import 'package:flutter_application/courses/presentation/pages/create_course.dart';
import 'package:flutter_application/courses/presentation/pages/course_detail_page.dart';
import 'package:flutter_application/courses/presentation/pages/join_course_page.dart';

// Core imports
import 'package:flutter_application/core/presentation/bindings/home_binding.dart';
import 'package:flutter_application/core/presentation/pages/main_page.dart';

import 'package:get/get.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String main = '/main';
  static const String createActivity = '/create-activity';
  static const String createCategory = '/create-category';
  static const String createCourse = '/create-course';
  static const String categories = '/categories';
  static const String editCategory = '/edit-category';
  static const String courseDetail = '/course-detail';
  static const String joinCourse = '/join-course';
  static const String prueba = '/prueba';

  static List<GetPage> pages = [
    GetPage(name: login, page: () => LoginPage(), binding: AuthBinding()),
    GetPage(name: signup, page: () => SignUpPage(), binding: SignUpBinding()),
    GetPage(
      name: home,
      page: () => const MainPage(),
      bindings: [HomeBinding()],
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
      binding: view_cat.CategoryGroupsBinding(),
    ),
    GetPage(
      name: '$editCategory/:id',
      page: () => EditCategoryPage(),
      binding: EditCategoryBinding(),
    ),
    GetPage(
      name: courseDetail,
      page: () => const CourseDetailPage(),
      bindings: [
        CourseDetailBinding(),
        view_cat.CategoryGroupsBinding(),
        CategoriesBinding(),
      ],
    ),
    GetPage(
      name: joinCourse,
      page: () => JoinCoursePage(),
      binding: JoinCourseBinding(),
    ),
    GetPage(
      name: prueba,
      page: () => const CategoriesPage(),
      binding: view_cat.CategoryGroupsBinding(),
    ),
    // Re estructura de github
  ];
}
