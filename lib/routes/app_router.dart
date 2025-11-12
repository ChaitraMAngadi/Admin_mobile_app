import 'package:admin_mobile_application/adminController/editPatientPage.dart';
import 'package:admin_mobile_application/adminController/patientVisitsPage.dart';
import 'package:admin_mobile_application/adminController/registerNewPatientPage.dart';
import 'package:admin_mobile_application/adminController/slotPage.dart';
import 'package:admin_mobile_application/adminDashboard.dart';
import 'package:admin_mobile_application/authenticationSCreen.dart';
import 'package:admin_mobile_application/loginPage.dart';
import 'package:admin_mobile_application/splashPage.dart';
import 'package:auto_route/auto_route.dart';
 import 'package:flutter/material.dart';

part 'app_router.gr.dart';

// dart run build_runner build --delete-conflicting-outputs

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
          page: SplashRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: LoginRoute.page,
        ),
        AutoRoute(
          page: AuthenticationRoute.page,
        ),
        AutoRoute(
          page: AdminDashboardRoute.page,
        ),
        AutoRoute(
          page: RegisterNewPatientRoute.page,
        ),
         AutoRoute(
          page: EditPatientAdminRoute.page,
        ),
         AutoRoute(
          page: PatientAdminOutvisitsRoute.page,
        ),
        AutoRoute(
          page: SlotRoute.page,
        ),
      ];
}
