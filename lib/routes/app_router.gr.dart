// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AdminDashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AdminDashboardPage(),
      );
    },
    AuthenticationRoute.name: (routeData) {
      final args = routeData.argsAs<AuthenticationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AuthenticationPage(
          key: args.key,
          email: args.email,
          password: args.password,
        ),
      );
    },
    EditPatientAdminRoute.name: (routeData) {
      final args = routeData.argsAs<EditPatientAdminRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditPatientAdminPage(
          key: args.key,
          patientId: args.patientId,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    PatientAdminOutvisitsRoute.name: (routeData) {
      final args = routeData.argsAs<PatientAdminOutvisitsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PatientAdminOutvisitsPage(
          key: args.key,
          patientId: args.patientId,
        ),
      );
    },
    RegisterNewPatientRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterNewPatientPage(),
      );
    },
    SlotRoute.name: (routeData) {
      final args = routeData.argsAs<SlotRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SlotPage(
          key: args.key,
          patientId: args.patientId,
          doctorname: args.doctorname,
        ),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashPage(),
      );
    },
  };
}

/// generated route for
/// [AdminDashboardPage]
class AdminDashboardRoute extends PageRouteInfo<void> {
  const AdminDashboardRoute({List<PageRouteInfo>? children})
      : super(
          AdminDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdminDashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AuthenticationPage]
class AuthenticationRoute extends PageRouteInfo<AuthenticationRouteArgs> {
  AuthenticationRoute({
    Key? key,
    required String email,
    required String password,
    List<PageRouteInfo>? children,
  }) : super(
          AuthenticationRoute.name,
          args: AuthenticationRouteArgs(
            key: key,
            email: email,
            password: password,
          ),
          initialChildren: children,
        );

  static const String name = 'AuthenticationRoute';

  static const PageInfo<AuthenticationRouteArgs> page =
      PageInfo<AuthenticationRouteArgs>(name);
}

class AuthenticationRouteArgs {
  const AuthenticationRouteArgs({
    this.key,
    required this.email,
    required this.password,
  });

  final Key? key;

  final String email;

  final String password;

  @override
  String toString() {
    return 'AuthenticationRouteArgs{key: $key, email: $email, password: $password}';
  }
}

/// generated route for
/// [EditPatientAdminPage]
class EditPatientAdminRoute extends PageRouteInfo<EditPatientAdminRouteArgs> {
  EditPatientAdminRoute({
    Key? key,
    required String patientId,
    List<PageRouteInfo>? children,
  }) : super(
          EditPatientAdminRoute.name,
          args: EditPatientAdminRouteArgs(
            key: key,
            patientId: patientId,
          ),
          initialChildren: children,
        );

  static const String name = 'EditPatientAdminRoute';

  static const PageInfo<EditPatientAdminRouteArgs> page =
      PageInfo<EditPatientAdminRouteArgs>(name);
}

class EditPatientAdminRouteArgs {
  const EditPatientAdminRouteArgs({
    this.key,
    required this.patientId,
  });

  final Key? key;

  final String patientId;

  @override
  String toString() {
    return 'EditPatientAdminRouteArgs{key: $key, patientId: $patientId}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PatientAdminOutvisitsPage]
class PatientAdminOutvisitsRoute
    extends PageRouteInfo<PatientAdminOutvisitsRouteArgs> {
  PatientAdminOutvisitsRoute({
    Key? key,
    required String patientId,
    List<PageRouteInfo>? children,
  }) : super(
          PatientAdminOutvisitsRoute.name,
          args: PatientAdminOutvisitsRouteArgs(
            key: key,
            patientId: patientId,
          ),
          initialChildren: children,
        );

  static const String name = 'PatientAdminOutvisitsRoute';

  static const PageInfo<PatientAdminOutvisitsRouteArgs> page =
      PageInfo<PatientAdminOutvisitsRouteArgs>(name);
}

class PatientAdminOutvisitsRouteArgs {
  const PatientAdminOutvisitsRouteArgs({
    this.key,
    required this.patientId,
  });

  final Key? key;

  final String patientId;

  @override
  String toString() {
    return 'PatientAdminOutvisitsRouteArgs{key: $key, patientId: $patientId}';
  }
}

/// generated route for
/// [RegisterNewPatientPage]
class RegisterNewPatientRoute extends PageRouteInfo<void> {
  const RegisterNewPatientRoute({List<PageRouteInfo>? children})
      : super(
          RegisterNewPatientRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterNewPatientRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SlotPage]
class SlotRoute extends PageRouteInfo<SlotRouteArgs> {
  SlotRoute({
    Key? key,
    required String patientId,
    required String doctorname,
    List<PageRouteInfo>? children,
  }) : super(
          SlotRoute.name,
          args: SlotRouteArgs(
            key: key,
            patientId: patientId,
            doctorname: doctorname,
          ),
          initialChildren: children,
        );

  static const String name = 'SlotRoute';

  static const PageInfo<SlotRouteArgs> page = PageInfo<SlotRouteArgs>(name);
}

class SlotRouteArgs {
  const SlotRouteArgs({
    this.key,
    required this.patientId,
    required this.doctorname,
  });

  final Key? key;

  final String patientId;

  final String doctorname;

  @override
  String toString() {
    return 'SlotRouteArgs{key: $key, patientId: $patientId, doctorname: $doctorname}';
  }
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
