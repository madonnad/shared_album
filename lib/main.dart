import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/firebase_options.dart';
import 'package:shared_photo/repositories/auth0_repository.dart';
import 'package:shared_photo/repositories/data_repository/data_repository.dart';
import 'package:shared_photo/repositories/firebase_messaging_repository.dart';
import 'package:shared_photo/repositories/notification_repository/notification_repository.dart';
import 'package:shared_photo/repositories/realtime_repository.dart';
import 'package:shared_photo/repositories/user_repository.dart';
import 'package:shared_photo/router/generate_route.dart';
import 'package:shared_photo/screens/loading.dart';
import 'package:shared_photo/screens/app_frame.dart';
import 'package:shared_photo/screens/auth/new_auth.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    String license = await rootBundle
        .loadString('assets/google_fonts/Dancing_Script/static/OFL.txt');
    yield LicenseEntryWithLineBreaks(['dancing_script'], license);
    license =
        await rootBundle.loadString('assets/google_fonts/DM_Mono/OFL.txt');
    yield LicenseEntryWithLineBreaks(['dm_mono'], license);
    license =
        await rootBundle.loadString('assets/google_fonts/Josefin_Sans/OFL.txt');
    yield LicenseEntryWithLineBreaks(['josefin_sans'], license);
    license = await rootBundle.loadString('assets/google_fonts/Lato/OFL.txt');
    yield LicenseEntryWithLineBreaks(['lato'], license);
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final cameras = await availableCameras();

  runApp(MainApp(
    cameras: cameras,
    settings: settings,
  ));
}

class MainApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final NotificationSettings settings;
  const MainApp({
    required this.cameras,
    required this.settings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));

    return RepositoryProvider(
      create: (context) => Auth0Repository(),
      child: BlocProvider(
        create: (context) => AppBloc(
          auth0repository: context.read<Auth0Repository>(),
          cameras: cameras,
        ),
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            switch (state.status) {
              case AppStatus.authenticated:
                return MultiRepositoryProvider(
                  providers: [
                    RepositoryProvider(
                      lazy: false,
                      create: (context) => RealtimeRepository(
                        user: context.read<AppBloc>().state.user,
                      ),
                    ),
                    RepositoryProvider(
                      create: (context) => NotificationRepository(
                        realtimeRepository: context.read<RealtimeRepository>(),
                        user: context.read<AppBloc>().state.user,
                      ),
                    ),
                    RepositoryProvider(
                      lazy: false,
                      create: (context) => FirebaseMessagingRepository(
                        user: context.read<AppBloc>().state.user,
                        settings: settings,
                        notificationRepository:
                            context.read<NotificationRepository>(),
                      ),
                    ),
                    RepositoryProvider(
                      lazy: false,
                      create: (context) => DataRepository(
                        realtimeRepository: context.read<RealtimeRepository>(),
                        notificationRepository:
                            context.read<NotificationRepository>(),
                        user: context.read<AppBloc>().state.user,
                      ),
                    ),
                    RepositoryProvider(
                      lazy: false,
                      create: (context) => UserRepository(
                        user: context.read<AppBloc>().state.user,
                        notificationRepository:
                            context.read<NotificationRepository>(),
                      ),
                    ),
                  ],
                  child: const MainAppView(),
                );
              case AppStatus.unauthenticated:
                return const MainAppView();
            }
          },
        ),
      ),
    );
  }
}

class MainAppView extends StatelessWidget {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkMode(),
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AuthenticatedState) {
            return const AppFrame();
          } else if (state is LoadingState) {
            return const LoadingScreen();
          } else {
            return const NewAuth();
          }
        },
      ),
      onGenerateRoute: onGenerateRoute,
    );
  }
}

ThemeData lwCustomTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
    scaffoldBackgroundColor: Colors.white,
    splashFactory: NoSplash.splashFactory,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color.fromRGBO(19, 19, 20, 1),
        surfaceTintColor: Colors.black),
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Colors.black,
    // ),
  );
}

ThemeData darkMode() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color.fromRGBO(19, 19, 20, 1),
    appBarTheme: AppBarTheme(
      color: Color.fromRGBO(19, 19, 20, 1),
      titleTextStyle: GoogleFonts.lato(
        color: Color.fromRGBO(242, 243, 247, 1),
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color.fromRGBO(19, 19, 20, 1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color.fromRGBO(34, 34, 38, 1),
      filled: true,
      hintStyle: GoogleFonts.lato(
        color: Color.fromRGBO(242, 243, 247, .55),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      //contentPadding: const EdgeInsets.all(20),
      prefixIconColor: Color.fromRGBO(242, 243, 247, .55),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(255, 98, 96, 1),
        disabledBackgroundColor: Color.fromRGBO(255, 98, 96, .5),
        foregroundColor: Color.fromRGBO(242, 243, 247, 1),
        disabledForegroundColor: Color.fromRGBO(242, 243, 247, .5),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        textStyle: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          width: 2.0,
          color: Color.fromRGBO(242, 243, 247, 1),
        ),
        foregroundColor: Color.fromRGBO(242, 243, 247, 1),
        disabledForegroundColor: Color.fromRGBO(242, 243, 247, .5),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        textStyle: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color.fromRGBO(242, 243, 247, 1),
        disabledForegroundColor: Color.fromRGBO(242, 243, 247, .5),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
