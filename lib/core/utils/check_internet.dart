// import 'dart:async';
// // import 'package:easy_localization/easy_localization.dart';

// import 'package:chat_app/core/utils/app_utils.dart';
// import 'package:chat_app/core/utils/snack_bar_type_enum.dart';
// // import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// class CheckInternetConnection {
//   // final InternetConnection internetConnection;
//   // late StreamSubscription<InternetStatus> listner;

//   CheckInternetConnection({required this.internetConnection});

//   void listener() {
//     listner = internetConnection.onStatusChange.listen((InternetStatus status) {
//       switch (status) {
//         case InternetStatus.connected:
//           if (!AppUtils.netConnect) {
//             AppUtils.showCustomSnackbar(
//                 'internet_return_connected', SnackType.SUCESS);
//             // AppUtils.netConnect = true;
//           }
//           break;
//         case InternetStatus.disconnected:
//           if (AppUtils.netConnect) {
//             AppUtils.showCustomSnackbar(
//                 'internet_is_disconnected', SnackType.FAILURE);
//             // AppUtils.netConnect = false;
//           }
//           break;
//       }
//     });
//   }

//   void cancel() {
//     listner.cancel();
//   }
// }
