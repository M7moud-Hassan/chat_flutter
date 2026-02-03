import 'package:chat_app/core/model/error_model.dart';
import 'package:chat_app/core/utils/snack_bar_type_enum.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app_utils.dart';

class DioConfig {
  final Dio dio;

  DioConfig({required this.dio});

  updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = '$baseUrl/api/';
  }

  Dio config() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        AppUtils.log(dio.options.baseUrl);
        if (!(AppUtils.netConnect)) return;
        if (options.method != 'get' &&
            options.method != 'GET' &&
            options.path != 'accounts/login/') {
          try {
            EasyLoading.show();
          } catch (e) {}
        }

        AppUtils.log(options.path);
        if (options.data is FormData) {
          AppUtils.log((options.data as FormData).fields.toString());
          AppUtils.log((options.data as FormData).files.toString());
        } else {
          AppUtils.log(options.data.toString());
        }
        final user = AppUtils.instance.getUser();
        if (user != null) {
          final local = AppUtils.instance.getLocale();
          AppUtils.log(user.deviceId ?? '');
          options.headers.addAll({
            "Authorization": "Bearer  ${user.access?.token}",
            'Accept-Language': local?.languageCode ?? 'ar'
          });
        }

        return handler.next(options);
      },
      onError: (error, handler) {
        if (EasyLoading.isShow) EasyLoading.dismiss();
        final respose = error.response;
        if (respose?.statusCode == 401) {}
        if (respose?.statusCode == 400 || respose?.statusCode == 404) {
          final data = ErrorModel.fromJson(respose?.data);
          for (var element in data) {
            AppUtils.showCustomSnackbar(
                title: element.key,
                element.messages.join('\n'),
                SnackType.FAILURE);
          }
        }
      },
      onResponse: (response, handler) {
        if (EasyLoading.isShow) EasyLoading.dismiss();
        AppUtils.log(response.data.toString());
        return handler.next(response);
      },
    ));
    return dio;
  }
}
