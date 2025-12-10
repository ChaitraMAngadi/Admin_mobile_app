import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';


@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final SecureStorage secureStorage = SecureStorage();
    // Constants.role = await secureStorage.readSecureData('role') ?? '';
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    // Constants.nursetoken = await secureStorage.readSecureData('nursetoken') ?? '';

    // Decide the next route
    // if (Constants.role == 'doctor' && Constants.token.isNotEmpty) {
    //   context.router.replaceAll([const HomeRoute()]);
    // } 
    // else 
    if (Constants.token.isNotEmpty) {
      context.router.replaceAll([const AdminDashboardRoute()]);
    } 
    // else if (Constants.nursetoken.isNotEmpty) {
    //   context.router.replaceAll([const StaffDashboardRoute()]);
    // } 
    else {
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
