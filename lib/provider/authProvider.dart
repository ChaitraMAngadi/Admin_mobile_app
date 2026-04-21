import 'dart:convert';


import 'package:admin_mobile_application/services/DeviceHeader.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/app_router.dart';

class Authprovider extends ChangeNotifier {
  final SecureStorage secureStorage = SecureStorage();

  Future<bool> login(
      String email, String password, BuildContext context) async {

    String url = "${Constants.baseUrl}/api/v1/admin/loginphone";
    final headers = await DeviceHeaders.getDeviceHeaders();

    print(url);
    print(email);
    print(password);
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
       await secureStorage.writeSecureData('token', responseData['token']);
        await secureStorage.writeSecureData('refreshtoken', responseData['refreshToken']);
        await secureStorage.readSecureData('token').then((value) {
          Constants.token = value;
        });

  await secureStorage.readSecureData('refreshtoken').then((value) {
          Constants.refreshtoken = value;
        });
        print("Constants.admintoken ${Constants.token}");
        print("Constants.adminrefreshtoken ${Constants.refreshtoken}");
        await secureStorage.writeSecureData("isLoggedIn", "true");

await secureStorage.writeSecureData(
  "biometricEnabled", "true"
);

await secureStorage.readSecureData('isLoggedIn').then((value) {
          Constants.isLoggedIn = value;
        });

      await secureStorage.readSecureData('biometricEnabled').then((value) {
          Constants.biometricEnabled = value;
        });
print(Constants.isLoggedIn);
print(Constants.biometricEnabled);

        print("Constants.token ${Constants.token}");

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Logged in sucessfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        Constants.token = await secureStorage.readSecureData('token') ?? '';

        // context.router.replaceAll([HomeRoute()]);

        // context.router.popUntilRoot();
        notifyListeners();
        return true;
        // context.router.popAndPush(OtpVerificationRoute());
      } else {
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.white),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return false;
      }
    } catch (e) {
      print(e);
      final error = SnackBar(
          backgroundColor: Colors.red[400], content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
      return false;
    }
  }

  Future<bool> sendOTP(
      String email, String password, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/loginotpphone";
    final headers = await DeviceHeaders.getDeviceHeaders();

    print(url);
    print(email);
    print(password);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 403 &&
        responseData['requiresLogoutConfirmation'] == true) {
      final pendingToken = responseData['token'] as String;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Too Many Active Sessions',
            style: TextStyle(
            
             fontWeight: FontWeight.bold,
             fontSize: 20
            ),),
            const SizedBox(height: 16,),
            const Text(
              'You are already logged in on 2 other devices. Do you want to log out from all other sessions and continue logging in here?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            ),
                        const SizedBox(height: 22,),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              Container(
                // width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                            const EdgeInsets.symmetric(
                                          vertical: 14,horizontal: 16
                                        )),
                                        backgroundColor: WidgetStateProperty.all(
                                          Colors.grey.shade300  ),
                                          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                                          foregroundColor: const WidgetStatePropertyAll(Colors.white),
                                        shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0))),
                                      ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No, Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
              const SizedBox(width: 16,),
              Container(
                // width: double.infinity,
                 decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: const BorderRadius.all(Radius.circular(16))
                                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(
                                        vertical: 14,horizontal: 16
                                      )),
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent  ),
                                        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                                        foregroundColor: const WidgetStatePropertyAll(Colors.white),
                                      shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(23.0))),
                                    ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Yes,Log Out All',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ],
            )
              ],
            ),
          ),
          
        ),
      );

      if (confirmed == true) {
        return await _forceLogoutAndSendOTP(
            email, password, pendingToken, context);
      }
      return false;
    }

      if (response.statusCode == 200 && responseData['success'] == true) {
        final responseData = jsonDecode(response.body);
        print(responseData);
      
      return await _handleOTPSuccess(responseData, context);

      } else {
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.white),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return false;
      }
    } catch (e) {
      print(e);
      final error = SnackBar(
          backgroundColor: Colors.red[400], content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
      return false;
    }
  }

  Future<bool> _forceLogoutAndSendOTP(
    String email, String password, String pendingToken, BuildContext context) async {
  try {
    // 1. Call force-logout API with token + confirm in body
    final logoutUrl = "${Constants.baseUrl}/api/v1/user/force-logout-mobile";
    final logoutHeaders = await DeviceHeaders.getDeviceHeaders();

    final logoutResponse = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        ...logoutHeaders,
      },
      body: jsonEncode({
        'token': pendingToken,   // backend reads from req.body.token
        'confirm': true,         // backend checks req.body.confirm
      }),
    );

    final logoutData = jsonDecode(logoutResponse.body);

    print(logoutData);

    // success: true covers both "cleared" and "alreadyCleared" cases
    if (logoutResponse.statusCode == 200 && logoutData['success'] == true) {
      // 2. Retry OTP automatically
      return await sendOTP(email, password, context);
    }
 
    _showSnackbar(
        context, logoutData['msg'] ?? 'Force logout failed', isError: true);
    return false;
  } catch (e) {
    _showSnackbar(context, e.toString(), isError: true);
    return false;
  } 
}

  Future<bool> _handleOTPSuccess(
    Map<String, dynamic> responseData, BuildContext context) async {
  await secureStorage.writeSecureData(
      'phone', responseData['phone'].toString());
  await secureStorage.readSecureData('phone').then((value) {
    Constants.phone = value.toString();
  });

  _showSnackbar(context, 'OTP sent successfully');
  notifyListeners();
  return true;
}

void _showSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError ? Colors.red[400] : Colors.green[400],
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ),
  );
}

  Future<void> resendOTP(
      String email, String password, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/loginotpphone";
    final headers = await DeviceHeaders.getDeviceHeaders();


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'OTP Sent sucessfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        // Constants.token = await secureStorage.readSecureData('token') ?? '';

        notifyListeners();
      } else {
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.white),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      print(e);
      final error = SnackBar(
          backgroundColor: Colors.red[400], content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
    }
  }

  Future<void> verifyphoneOtp(
      String email, String otp, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/verifyotpphone";
final headers = await DeviceHeaders.getDeviceHeaders();


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        await secureStorage.writeSecureData('token', responseData['token']);
        await secureStorage.writeSecureData('refreshtoken', responseData['refreshToken']);
        await secureStorage.readSecureData('token').then((value) {
          Constants.token = value;
        });

  await secureStorage.readSecureData('refreshtoken').then((value) {
          Constants.refreshtoken = value;
        });
        print("Constants.admintoken ${Constants.token}");
        print("Constants.adminrefreshtoken ${Constants.refreshtoken}");
        
        await secureStorage.writeSecureData('role', responseData['role']);
        await secureStorage.readSecureData('role').then((value) {
          Constants.role = value;
        });

        print("Constants.token ${Constants.token}");
        print("Role ${Constants.role}");

  await secureStorage.writeSecureData("isLoggedIn", "true");

await secureStorage.writeSecureData(
  "biometricEnabled", "true"
);

await secureStorage.readSecureData('isLoggedIn').then((value) {
          Constants.isLoggedIn = value;
        });

      await secureStorage.readSecureData('biometricEnabled').then((value) {
          Constants.biometricEnabled = value;
        });
print(Constants.isLoggedIn);
print(Constants.biometricEnabled);

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

       context.router.replace(const AdminDashboardRoute());


        // responseData['role'] =='doctor'? context.router.popAndPush(HomeRoute()):MaterialPageRoute(builder: (context) => const AdminDashboardPage());
        // Constants.otpverification = true;
        // context.router.popAndPush(HomeNewRoute());

        // context.router.replaceAll([HomeRoute()]);

        // context.router.popUntilRoot();
        notifyListeners();
        // return true;
      } else {
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(responseData['msg'],
                style: TextStyle(color: Colors.grey[50])));
        Constants.otpverification = false;
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // return false;
      }
      //  else {
      //   // result = '';

      //   // If the server returns an error response, throw an exception
      //   Constants.otpverification = false;
      //   throw Exception(response.body);
      // }
    } catch (e) {
      final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
      print(e);
      // return false;
    }
  }
}
