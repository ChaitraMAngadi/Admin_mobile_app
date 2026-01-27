
import 'package:admin_mobile_application/main.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/biometricservice.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:flutter/material.dart';
 
 class AppLockWrapper extends StatefulWidget {
  final Widget child;
  const AppLockWrapper({required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  final biometricService = BiometricService();
  final SecureStorage secureStorage = SecureStorage();

  bool _locked = false;
  bool _isAuthenticating = false;

  bool _showUnlockScreen = false;


  @override
  void initState() {
    super.initState();

    // 🔥 ONLY once – fresh app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLock();
    });
  }

//   Future<void> _checkAndLock() async {
//   if (_isAuthenticating) return;

//   final isLoggedIn =
//       await secureStorage.readSecureData("isLoggedIn") == "true";

//   final appLockEnabled =
//       await secureStorage.readSecureData("appLockEnabled") != "false";
//   // 👆 default TRUE

//   if (!isLoggedIn || !appLockEnabled) return;

//   final deviceLockAvailable =
//       await biometricService.isDeviceLockAvailable();

//   if (!deviceLockAvailable) return;

//   _isAuthenticating = true;
//   setState(() => _locked = true);

//   final success =
//       await biometricService.authenticateWithDeviceLock();

//   if (!mounted) return;

//   _isAuthenticating = false;
//   setState(() => _locked = !success);
// }

Future<void> _checkAndLock() async {
  if (_isAuthenticating) return;

  final isLoggedIn =
      await secureStorage.readSecureData("isLoggedIn") == "true";

  final appLockEnabled =
      await secureStorage.readSecureData("appLockEnabled") != "false";

  if (!isLoggedIn || !appLockEnabled) return;

  final deviceLockAvailable =
      await biometricService.isDeviceLockAvailable();

  if (!deviceLockAvailable) return;

  _isAuthenticating = true;
  setState(() {
    _locked = true;
    _showUnlockScreen = false;
  });

  final result =
      await biometricService.authenticateWithDeviceLock();

  if (!mounted) return;

  _isAuthenticating = false;

  // 🔴 CANCEL / ERROR / FAIL
  if (result != true) {
    setState(() {
      _locked = false;
      _showUnlockScreen = true;
    });
    return;
  }

  // ✅ SUCCESS
  setState(() {
    _locked = false;
    _showUnlockScreen = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // if (_locked)
        //   Positioned.fill(
        //     child: Container(
        //       color: Colors.black.withOpacity(0.85),
        //       child: const Center(
        //         child: CircularProgressIndicator(color: Colors.white),
        //       ),
        //     ),
        //   ),

        if (_locked && _isAuthenticating)
  Positioned.fill(
    child: Container(
      color: Colors.black.withOpacity(0.85),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    ),
  ),

  if (_showUnlockScreen) _unlockScreen(context),

      ],
    );
  }

  Widget _unlockScreen(BuildContext context) {
  return Positioned.fill(
    child: Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Card(
           
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 60, color: Color(0xFF0857C0)),
                const SizedBox(height: 16),
                const Text(
                  "App is locked, Please select one of the options below to continue.",
                  style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
            
                /// 🔓 Unlock again
                
                ElevatedButton.icon(
                  style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
            backgroundColor: WidgetStatePropertyAll(Color(0XFF0857C0)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
                  onPressed: () {
                    setState(() => _showUnlockScreen = false);
                    _checkAndLock();
                  },
                  icon: const Icon(Icons.fingerprint,
                  size: 20,
                  color: Colors.white,),
                  label: const Text("Unlock Again",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16
                  ),),
                ),
            
                const SizedBox(height: 16),
                ElevatedButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: 14, horizontal: 58)),
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          //  onPressed: () async {
          //   secureStorage.deleteSecureData('token');
          //           secureStorage.deleteSecureData("isLoggedIn");
          //           secureStorage.deleteSecureData("appLockEnabled");
          //           secureStorage.deleteSecureData("biometricEnabled");
          //           setState(() {});
          //           Constants.token =
          //               await secureStorage.readSecureData('token') ?? '';

          //           context.router.replaceAll([HomeRoute()]);
                    
          // },
          onPressed: () async {
  // 1️⃣ Clear secure storage
  await secureStorage.deleteSecureData('token');
  await secureStorage.deleteSecureData("isLoggedIn");
  await secureStorage.deleteSecureData("appLockEnabled");
  await secureStorage.deleteSecureData("biometricEnabled");

  Constants.token = '';

  // 2️⃣ VERY IMPORTANT
  if (!mounted) return;

  // 3️⃣ Navigate safely (root)
  // context.router.replaceAll([SplashRoute()]);
  //  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
  //   MaterialPageRoute(builder: (_) => const SplashPage()),
  //   (route) => false,
  // );

    setState(() {
    _locked = false;
    _showUnlockScreen = false;
    _isAuthenticating = false;
  });
  appRouter.replaceAll([const SplashRoute()]);
},

          child: const Text(
            "Logout",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0XFF0857C0),
            ),
          ),
        ),
        SizedBox(height: 16,)
            
                /// 🚪 Logout (safe fallback)
                // TextButton(
                //   onPressed: () async {
                //     await secureStorage.writeSecureData("isLoggedIn", "false");
                //     // navigate to login if needed
                //   },
                //   child: const Text(
                //     "Logout",
                //     style: TextStyle(color: Colors.white70),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
