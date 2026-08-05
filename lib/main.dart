import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/patient_provider.dart';
import 'config/app_routes.dart';

void main() async {
  // Initialize storage first
  await storageService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(
      apiService: apiService,
      storageService: storageService,
    );
    // Initialize auth state
    _authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider (must be first)
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        // User provider
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(apiService: apiService),
        ),
        // Patient provider
        ChangeNotifierProvider<PatientProvider>(
          create: (_) => PatientProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'LifePass',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32), // Healthcare green
          ),
          useMaterial3: true,
        ),
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
