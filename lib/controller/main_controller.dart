import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt index = 0.obs; 

  void changeTab(int i) => index.value = i;
}
