import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/home_screen.dart';
import '../screens/profile/create_profile_screen.dart';
import '../screens/profile/view_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/medical/diseases_screen.dart';
import '../screens/medical/allergies_screen.dart';
import '../screens/medical/medicines_screen.dart';
import '../screens/emergency/emergency_profile_screen.dart';
import '../screens/emergency/emergency_qr_screen.dart';
import '../screens/reports/reports_dashboard_screen.dart';
import '../screens/reports/report_upload_screen.dart';
import '../screens/reports/report_history_screen.dart';
import '../screens/reports/report_summary_screen.dart';
import '../screens/settings/settings_dashboard_screen.dart';
import '../screens/settings/account_settings_screen.dart';
import '../screens/settings/change_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String createProfile = '/profile/create';
  static const String viewProfile = '/profile/view';
  static const String editProfile = '/profile/edit';
  static const String diseases = '/medical/diseases';
  static const String allergies = '/medical/allergies';
  static const String medicines = '/medical/medicines';
  static const String emergencyProfile = '/emergency/profile';
  static const String emergencyQr = '/emergency/qr';
  static const String reportsDashboard = '/reports';
  static const String reportsUpload = '/reports/upload';
  static const String reportsHistory = '/reports/history';
  static const String reportsSummary = '/reports/summary';
  static const String settingsDashboard = '/settings';
  static const String accountSettings = '/settings/account';
  static const String changePassword = '/settings/change-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: const RouteSettings(name: splash),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: login),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: const RouteSettings(name: register),
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: const RouteSettings(name: forgotPassword),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: const RouteSettings(name: home),
        );
      case createProfile:
        return MaterialPageRoute(
          builder: (_) => const CreateProfileScreen(),
          settings: const RouteSettings(name: createProfile),
        );
      case viewProfile:
        return MaterialPageRoute(
          builder: (_) => const ViewProfileScreen(),
          settings: const RouteSettings(name: viewProfile),
        );
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: const RouteSettings(name: editProfile),
        );
      case diseases:
        return MaterialPageRoute(
          builder: (_) => const DiseasesScreen(),
          settings: const RouteSettings(name: diseases),
        );
      case allergies:
        return MaterialPageRoute(
          builder: (_) => const AllergiesScreen(),
          settings: const RouteSettings(name: allergies),
        );
      case medicines:
        return MaterialPageRoute(
          builder: (_) => const MedicinesScreen(),
          settings: const RouteSettings(name: medicines),
        );
      case emergencyProfile:
        return MaterialPageRoute(
          builder: (_) => const EmergencyProfileScreen(),
          settings: const RouteSettings(name: emergencyProfile),
        );
      case emergencyQr:
        return MaterialPageRoute(
          builder: (_) => const EmergencyQrScreen(),
          settings: const RouteSettings(name: emergencyQr),
        );
      case reportsDashboard:
        return MaterialPageRoute(
          builder: (_) => const ReportsDashboardScreen(),
          settings: const RouteSettings(name: reportsDashboard),
        );
      case reportsUpload:
        return MaterialPageRoute(
          builder: (_) => const ReportUploadScreen(),
          settings: const RouteSettings(name: reportsUpload),
        );
      case reportsHistory:
        return MaterialPageRoute(
          builder: (_) => const ReportHistoryScreen(),
          settings: const RouteSettings(name: reportsHistory),
        );
      case reportsSummary:
        return MaterialPageRoute(
          builder: (_) => const ReportSummaryScreen(),
          settings: const RouteSettings(name: reportsSummary),
        );
      case settingsDashboard:
        return MaterialPageRoute(
          builder: (_) => const SettingsDashboardScreen(),
          settings: const RouteSettings(name: settingsDashboard),
        );
      case accountSettings:
        return MaterialPageRoute(
          builder: (_) => const AccountSettingsScreen(),
          settings: const RouteSettings(name: accountSettings),
        );
      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: const RouteSettings(name: changePassword),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
