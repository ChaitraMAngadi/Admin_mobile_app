import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check device supports ANY lock (biometric OR PIN)
  Future<bool> isDeviceLockAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  // /// Show SYSTEM LOCK (fingerprint / pin / pattern)
  // Future<bool> authenticateWithDeviceLock() async {
  //   try {
  //     return await _auth.authenticate(
  //       localizedReason: 'Unlock app to continue',
  //       biometricOnly: false, // 🔥 THIS IS THE MAGIC
  //       // stickyAuth: true,
  //     );
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<bool?> authenticateWithDeviceLock() async {
  try {
    final result = await _auth.authenticate(
      localizedReason: 'Unlock app to continue',
      biometricOnly: false,
      // stickyAuth: false,
      // useErrorDialogs: true,
    );
    return result;
  } catch (e) {
    return null; // 👈 VERY IMPORTANT
  }
}
}
