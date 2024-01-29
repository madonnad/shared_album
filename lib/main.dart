import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/bloc/bloc/profile_bloc.dart';
import 'package:shared_photo/repositories/auth0_repository.dart';
import 'package:shared_photo/repositories/go_repository.dart';
import 'package:shared_photo/router/generate_route.dart';
import 'package:shared_photo/screens/auth.dart';
import 'package:shared_photo/screens/loading.dart';
import 'package:shared_photo/screens/new_app_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final auth0Repository = Auth0Repository();
  final goRepository = GoRepository();
  final cameras = await availableCameras();

  runApp(MainApp(
    auth0Repository: auth0Repository,
    goRepository: goRepository,
    cameras: cameras,
  ));
}

class MainApp extends StatelessWidget {
  final Auth0Repository _auth0Repository;
  final GoRepository _goRepository;
  final List<CameraDescription> cameras;
  const MainApp({
    required Auth0Repository auth0Repository,
    required GoRepository goRepository,
    required this.cameras,
    super.key,
  })  : _auth0Repository = auth0Repository,
        _goRepository = goRepository;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: _auth0Repository,
        ),
        RepositoryProvider.value(
          value: _goRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              auth0repository: _auth0Repository,
              cameras: cameras,
            ),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              appBloc: context.read<AppBloc>(),
              goRepository: _goRepository,
            ),
          ),
        ],
        child: const MainAppView(),
      ),
    );
  }
}

class MainAppView extends StatelessWidget {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
        scaffoldBackgroundColor: Colors.white,
        splashFactory: NoSplash.splashFactory,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.black, surfaceTintColor: Colors.black),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AuthenticatedState) {
            return const NewAppFrame();
          } else if (state is LoadingState) {
            return const LoadingScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
      onGenerateRoute: onGenerateRoute,
    );
  }
}
