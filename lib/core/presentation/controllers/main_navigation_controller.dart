import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  String get currentTitle {
    switch (currentIndex.value) {
      case 0:
        return 'Cursos';
      case 1:
        return '';
      case 2:
        return 'Perfil';
      default:
        return 'Cursos';
    }
  }
}







