import 'package:get/get.dart';
import '../model/item.dart';
import '../service/api_service.dart';

class DetailController extends GetxController {
  final ApiService _api = ApiService();

  final Item selected = Get.arguments as Item;

  final Rxn<Item> item = Rxn<Item>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      item.value = await _api.fetchItem(selected.id);
    } catch (e) {
      errorMessage.value =
          e is ApiException ? e.message : 'Terjadi kesalahan tak terduga.';
    } finally {
      isLoading.value = false;
    }
  }
}
