import 'package:chat_app/chat/data/datasources/chat_db.dart';
import 'package:chat_app/chat/data/datasources/chat_db_impl.dart';
import 'package:chat_app/chat/data/repositories/chat_repo_impl.dart';
import 'package:chat_app/chat/domain/repositories/chat_repo.dart';
import 'package:chat_app/chat/domain/usercases/add_attachment_use_case.dart';
import 'package:chat_app/chat/domain/usercases/create_room_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_admin_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_categories_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_messages_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_rooms_use_case.dart';
import 'package:chat_app/chat/domain/usercases/login_use_case.dart';
import 'package:chat_app/chat/domain/usercases/update_info_user_case.dart';
import 'package:chat_app/chat/presentation/bloc/categories/categories_bloc.dart';
import 'package:chat_app/chat/presentation/bloc/home/home_bloc.dart';
import 'package:chat_app/chat/presentation/bloc/login/login_bloc.dart';
import 'package:chat_app/core/conts/api.dart';
import 'package:chat_app/core/utils/app_config.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/core/utils/app_utils_imp.dart';
import 'package:chat_app/core/utils/calling.dart';
import 'package:chat_app/core/utils/check_internet.dart';
import 'package:chat_app/core/utils/dio.dart';
import 'package:chat_app/core/utils/notification.dart';
import 'package:dio/dio.dart';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = AppUtils.sl;
Future<void> init() async {
  sl.registerFactory<AppUtils>(() => AppUtilsImp(
        notificationServices: NotificationServices(),
        dio: sl<DioConfig>(instanceName: 'dioConfig'),
        // checkServer: sl<CheckInternetConnection>(instanceName: 'check_server'),
        // checkinternet:
        //     sl<CheckInternetConnection>(instanceName: 'check_internet'),
        prefs: sl(),
      ));
  sl.registerSingleton<Dio>(
      Dio(BaseOptions(
        baseUrl: Api.baseUrl,
        connectTimeout: const Duration(milliseconds: 20000),
        receiveTimeout: const Duration(milliseconds: 20000),
      )),
      instanceName: 'dio');
  // sl.registerSingleton<InternetConnection>(InternetConnection(),
  //     instanceName: 'internet');
  // sl.registerSingleton<InternetConnection>(
  //     InternetConnection.createInstance(
  //       customCheckOptions: [
  //         InternetCheckOption(uri: Uri.parse(Api.domain)),
  //       ],
  //     ),
  //     instanceName: 'server');

  sl.registerSingleton<DioConfig>(DioConfig(dio: sl(instanceName: 'dio')),
      instanceName: 'dioConfig');
  sl.registerSingleton<Dio>(sl<DioConfig>(instanceName: 'dioConfig').config());

  sl.registerLazySingleton<ChatDB>(
    () => ChatDBImpl(dio: sl<DioConfig>(instanceName: 'dioConfig').config()),
  );
  sl.registerLazySingleton<ChatRepo>(
      () => ChatRepoImpl(chatdb: sl(), calling: sl()));

  // sl.registerSingleton<CheckInternetConnection>(
  //     CheckInternetConnection(internetConnection: sl(instanceName: 'server'))
  //       ..listener(
  //           messageConnect: 'server return connected',
  //           messageDisconnect: 'server disconnected'),
  //     instanceName: 'check_server');
  // sl.registerSingleton<CheckInternetConnection>(
  //     CheckInternetConnection(internetConnection: sl(instanceName: 'internet'))
  //       ..listener(),
  //     instanceName: 'check_internet');

  sl.registerSingleton<Calling>(Calling());

  sl.registerSingletonAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  sl.registerSingleton<AppConfig>(
    AppConfig(sharedPreferences: await SharedPreferences.getInstance())
      ..loadConfig(),
  );

  sl.registerFactory(
      () => HomeBloc(createRoomUseCase: sl(), getRoomsUseCase: sl()));
  sl.registerFactory(() => LoginBloc(loginUSeCase: sl()));
  sl.registerFactory(() => CategoriesBloc(getCategoriesUseCase: sl()));
  sl.registerLazySingleton(() => CreateRoomUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => GetRoomsUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => AddAttachmentUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => GetAdminUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => UpdateInfoUserCase(chatRepo: sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(chatRepo: sl()));
  sl.registerLazySingleton(() => LoginUSeCase(chatRepo: sl()));

  // if (AppUtils.instance.getUser() == null) {
  // await sl<ChatRepo>().login();
  // } else {
  //   if (AppUtils.user!.access!.isExpired) {
  //     await sl<ChatRepo>().login();
  //   }
}
