import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/blocs/resource/resource_bloc.dart';
import 'package:studystack/firebase_options.dart';
import 'package:studystack/respositories/authentication.dart';
import 'package:studystack/respositories/database.dart';
import 'package:studystack/screens/authentication/login_screen.dart';
import 'package:studystack/screens/authentication/signup_screen.dart';
import 'package:studystack/screens/home/add_subject_screen.dart';
import 'package:studystack/screens/home/home_screen.dart';
import 'package:studystack/screens/home/search_screen.dart';
import 'package:studystack/screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final databaseRepository = DatabaseRepository();
  final authenticationRepository = AuthenticationRepository();
  runApp(
    MyApp(
      authenticationRepository: authenticationRepository,
      databaseRepository: databaseRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;
  final DatabaseRepository databaseRepository;
  const MyApp(
      {super.key,
      required this.authenticationRepository,
      required this.databaseRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
            create: (context) => AuthenticationRepository()),
        RepositoryProvider<DatabaseRepository>(
            create: (context) => DatabaseRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
                authenticationRepository: authenticationRepository),
          ),
          BlocProvider<ResourceBloc>(
            create: (context) => ResourceBloc(),
          ),
        ],
        child: MaterialApp(
          title: 'StudyStack',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.blueGrey[900],
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.poppinsTextTheme().copyWith(
              headlineLarge: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              titleLarge: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black),
              ),
              labelStyle: TextStyle(color: Colors.grey),
              prefixIconColor: Colors.grey,
              suffixIconColor: Colors.grey,
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/': (context) => HomeScreen(),
            '/splash': (context) => SplashScreen(),
            '/search': (context) => SearchScreen(),
            '/profile': (context) => ProfileScreen(),
            '/add-subject': (context) => AddSubjectScreen(),
            '/login': (context) => LoginScreen(),
            '/sign-up': (context) => SignupScreen(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else if (state is AuthenticationUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          }
        },
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
