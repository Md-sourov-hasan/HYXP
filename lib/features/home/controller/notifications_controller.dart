import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxList<Map<String, String>> notifications =
      <Map<String, String>>[
        {
          'title': '20% off',
          'message': 'You will get flat 20% off next 3 months.',
          'time': 'TUE, 7:30 PM',
        },
        {
          'title': 'MoneyBack',
          'message': 'You will get flat 20% off next 3 months.',
          'time': 'TUE, 7:30 PM',
        },
        {
          'title': 'Offer! Offer!',
          'message': 'You will get flat 20% off next 3 months.',
          'time': 'TUE, 7:30 PM',
        },
      ].obs;
}
