import 'dart:async';

import 'package:admin_mobile_application/provider/authProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  String? comingSMS = '';
  TextEditingController otpcontroller = TextEditingController();
  // late OTPTextEditController otpTextEditController;
  // late OTPInteractor otpInteractor;
  Timer? _timer;
  int _start = 100; // Set your countdown time in seconds
  bool _isButtonDisabled = true;
  final SecureStorage secureStorage = SecureStorage();
  bool _isVerifying = false;

  @override
  void initState() {
    // initSmsListener();
    super.initState();
    startTimer();
  }

  void startTimer() {
    _start = 100; // Reset the timer to 30 seconds
    _isButtonDisabled = true;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonDisabled = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendOtp() {
    Authprovider authprovider = context.read<Authprovider>();
    authprovider.resendOTP(widget.email, widget.password, context);
    // authprovider.resendOtp(Constants.phone, context);
    // // Logic to resend the OTP

    // if (widget.input!.contains(RegExp(r'[@.com]'))) {
    //   authenticationProvider.loginwithemail(widget.input ?? "", context);
    //   print("Logged in with email");
    //   print("OTP Resent");
    // } else {
    //   authenticationProvider.loginwithphone(
    //       widget.input ?? "", context); // Ensure this method is defined
    //   print("Logged in with phone");
    //   print("OTP Resent");
    // }

    // Restart the timer after resending
    startTimer();
  }

  @override
  void dispose() {
    print('Unregistered Listener');
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Authprovider authprovider = context.read<Authprovider>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.router.replaceAll([LoginRoute()]);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(
                      color: Colors.black26,
                      strokeAlign: BorderSide.strokeAlignOutside)),
              shadowColor: Colors.black,
              borderOnForeground: true,
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Verification Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'We have sent OTP code to Registered phone number ${Constants.phone}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PinCodeTextField(
                        controller: otpcontroller,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        autoFocus: true,
                        appContext: context,
                        length: 6,
                        pastedTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          activeColor: AppColors.secondary,
                          selectedColor: AppColors.primary,
                          selectedFillColor: AppColors.badgeBg,
                          inactiveColor: Colors.grey,
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 40,
                          fieldWidth: 40,
                          activeFillColor: AppColors.badgeBg,
                        ),
                        cursorColor: Colors.black,
                        animationDuration: const Duration(milliseconds: 300),
                        // controller: otpTextEditController,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(12)),
                    //     gradient: AppColors.primaryGradient,
                    //   ),
                    //   width: double.infinity,
                    //   child: FilledButton(
                    //       style: ButtonStyle(
                    //         padding: WidgetStateProperty.all(
                    //             const EdgeInsets.symmetric(
                    //           vertical: 14,
                    //         )),
                    //         backgroundColor: WidgetStateProperty.all(
                    //             Colors.transparent),
                    //             shadowColor: WidgetStatePropertyAll(Colors.transparent),
                    //         shape: WidgetStateProperty.all(
                    //             RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(23.0))),
                    //       ),
                    //       onPressed: () async {
                    //         // bool isloggedin = 
                    //         await authprovider.verifyphoneOtp(
                    //             widget.email, otpcontroller.text, context);

                    //             Constants.role = await secureStorage.readSecureData('role') ?? '';

                    //         // isloggedin
                    //         //     ? Constants.role =='doctor'? context.router.popAndPush(HomeRoute()):MaterialPageRoute(builder: (context) => const AdminDashboardPage())
                    //             // context.router.popAndPush(
                    //             //     const AuthenticationRoute())
                    //             // : null;
                    //         // context.router.popAndPush(HomeRoute());
                    //       },
                    //       child: const Text(
                    //         'Continue',
                    //         style: TextStyle(
                    //             fontSize: 16, fontWeight: FontWeight.bold),
                    //       )),
                    // ),

                    Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    gradient: AppColors.primaryGradient,
  ),
  width: double.infinity,
  child: FilledButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14)),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.0))),
      ),
      onPressed: _isVerifying
          ? null
          : () async {
              setState(() {
                _isVerifying = true;
              });

              try {
                await authprovider.verifyphoneOtp(
                    widget.email, otpcontroller.text, context);

                Constants.role =
                    await secureStorage.readSecureData('role') ?? '';
              } finally {
                if (mounted) {
                  setState(() {
                    _isVerifying = false;
                  });
                }
              }
            },
      child: _isVerifying
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      // style: const ButtonStyle(
                      //   backgroundColor: WidgetStatePropertyAll(Colors.transparent),

                      // ),
                      onPressed: _isButtonDisabled ? null : resendOtp,
                      child: Text(
                        _isButtonDisabled
                            ? "Resend OTP in $_start s"
                            : "Resend OTP",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(""),

                        TextButton(onPressed: (){
                                  openUrl("https://app.ppldoc.com/help");
                                }, child: const Text("Need Help?",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.lightBlue,
                                ),)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> openUrl(String url) async {
  final Uri uri = Uri.parse(url);

  try {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Always open in browser
    );
  } catch (e) {
    print("URL Launch Error: $e");
  }
}
}
