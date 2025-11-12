import 'dart:convert';


import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../routes/app_router.dart';

class Authprovider extends ChangeNotifier {
  final SecureStorage secureStorage = SecureStorage();

  Future<bool> login(
      String email, String password, BuildContext context) async {

    String url = "${Constants.baseUrl}/api/v1/doctor/loginphone";
    print(url);
    print(email);
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['token']);
        await secureStorage.writeSecureData('token', responseData['token']);
        await secureStorage.readSecureData('token').then((value) {
          Constants.token = value;
        });

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
    String url = "${Constants.baseUrl}/api/v1/user/login";
    print(url);
    print(email);
    print(password);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        // print(responseData['token']);
        // await secureStorage.writeSecureData('token', responseData['token']);
        // await secureStorage.readSecureData('token').then((value) {
        //   Constants.token = value;
        // });

        // print("Constants.token ${Constants.token}");

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'OTP Sent sucessfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        // Constants.token = await secureStorage.readSecureData('token') ?? '';

        notifyListeners();
        return true;
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

  Future<void> resendOTP(
      String email, String password, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/doctor/loginotpphone";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
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
    String url = "${Constants.baseUrl}/api/v1/user/verifyotp";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print(responseData);
        print(responseData['token']);
        await secureStorage.writeSecureData('token', responseData['token']);
        await secureStorage.readSecureData('token').then((value) {
          Constants.token = value;
        });

        await secureStorage.writeSecureData('role', responseData['role']);
        await secureStorage.readSecureData('role').then((value) {
          Constants.role = value;
        });

        print("Constants.token ${Constants.token}");
        print("Role ${Constants.role}");

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

        if (responseData['role'] == "doctor") {
      // context.router.replace(const HomeRoute());
    } else if (responseData['role'] == "admin") {
     context.router.replace(const AdminDashboardRoute());
    }


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
