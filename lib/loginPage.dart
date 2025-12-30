import 'package:admin_mobile_application/provider/authProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final SecureStorage secureStorage = SecureStorage();
  final loginformkey = GlobalKey<FormState>();
  late Future loginphone;
  bool _obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Authprovider authprovider = context.read<Authprovider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.height * 0.3,
                      // child:
                      //  Image.asset(
                      //     fit: BoxFit.cover, "assets/images/logonew.png"),
                    ),
                    const Text(
                      'Sign in to your account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // const Text(
                    //   'Enter your Email.',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //   ),
                    // ),
                    const SizedBox(
                      height: 12,
                    ),
                    Form(
                        key: loginformkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            TextFormField(
                              controller: emailController,
                              cursorColor: const Color(0Xff2556B9),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9.@]')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // No error for empty value
                                }

                                const emailRegex =
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                if (!RegExp(emailRegex).hasMatch(value!)) {
                                  return 'Enter a valid email address';
                                }
                                return null; // Return null if the input is valid
                              },
                              decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 16, top: 14, bottom: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  hintText: 'Enter email',
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff333333)
                                          .withOpacity(0.5))),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            TextFormField(
                              obscureText: _obscureText,
                              controller: passwordController,
                              cursorColor: const Color(0Xff2556B9),
                             
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter password';
                                }

                                return null; // Return null if validation is successful
                              },
                              decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 16, top: 14, bottom: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff333333)
                                          .withOpacity(0.5))),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                      vertical: 14,
                                    )),
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color(0Xff2556B9)),
                                    shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(23.0))),
                                  ),
                                  onPressed: () async {
                                    if (loginformkey.currentState!.validate()) {
                                      final inputemailText =
                                          emailController.text.trim().toLowerCase();
                                      final passwordText =
                                          passwordController.text;
                                          // print(inputemailText);
                                      // loginwithphone(inputText, context);

                                      // if (inputText == "8217309343") {
                                      //   // authprovider.loginphone(
                                      //   //     inputText, context);
                                      //    bool isLogged = await authprovider.loginphone(
                                      //         inputText, context);

                                      //     // Close loading dialog
                                      //     Navigator.of(context).pop();

                                      //     if (isLogged) {
                                      //       // Force rebuild of HomePage to pick up new token
                                      //       // Use pushAndPopUntil to clear the navigation stack
                                      //       context.router.pushAndPopUntil(
                                      //         HomeRoute(),
                                      //         predicate: (_) => false,
                                      //       );
                                      //     }
                                      // Show loading dialog
                                      // showDialog(
                                      //   context: context,
                                      //   barrierDismissible: false,
                                      //   builder: (BuildContext context) {
                                      //     return const Center(
                                      //       child: CircularProgressIndicator(),
                                      //     );
                                      //   },
                                      // );

                                      // if (inputText == "8217309343") {
                                      //   bool isLogged = await authprovider
                                      //       .loginphone(inputText, context);

                                      //   // Close loading dialog
                                      //   Navigator.of(context).pop();

                                      //   if (isLogged) {
                                      //     // Force rebuild of HomePage to pick up new token
                                      //     // Use pushAndPopUntil to clear the navigation stack
                                      //     context.router.pushAndPopUntil(
                                      //       HomeRoute(),
                                      //       predicate: (_) => false,
                                      //     );
                                      //   }

                                      //   // bool islogged = await authprovider
                                      //   //     .loginphone(inputText, context);

                                      //   // await islogged
                                      //   //     ? context.router
                                      //   //         .popAndPush(HomeRoute())
                                      //   //     : null;
                                      // } else {

                                      //   bool isotpsent = await authprovider
                                      //       .loginwithphone(inputText, context);

                                      //   isotpsent
                                      //       ? context.router.replaceAll(
                                      //           [OtpVerificationRoute()])
                                      //       : null;
                                      // }

                                      if (inputemailText == "damodar@gmail.com" && passwordText =="8217309343") {
                                        print(inputemailText);
                                        bool isloggedin =
                                            await authprovider.login(
                                                inputemailText,
                                                passwordText,
                                                context);

                                        isloggedin
                                            ? context.router
                                                .replaceAll([AdminDashboardRoute()])
                                            // context.router.popAndPush(
                                            //     const AuthenticationRoute())
                                            : null;
                                      } 
                                      else {
                                        bool isloggedin =
                                            await authprovider.sendOTP(
                                                inputemailText,
                                                passwordText,
                                                context);

                                        isloggedin
                                            ? context.router
                                                .replaceAll([AuthenticationRoute(
                                                email: inputemailText,
                                                password: passwordText,
                                              )])
                                            : null;
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
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
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ))
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
