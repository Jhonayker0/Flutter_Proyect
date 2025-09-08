import 'package:flutter/material.dart';
import 'package:flutter_application/presentation/pages/view_categories_page.dart';
import 'package:get/get.dart';
import '../controllers/course_detail_controller.dart';
import 'course_activities_tab.dart';
import 'course_students_tab.dart';
import 'course_info_tab.dart';

class CourseDetailPage extends GetView<CourseDetailController> {
  const CourseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.course.title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: const [
          CourseActivitiesTab(),
          CourseStudentsTab(),
          CategoryGroupsPage(),
          CourseInfoTab(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Estudiantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Categorias',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Información',
          ),
        ],
      )),
    );
  }
}
