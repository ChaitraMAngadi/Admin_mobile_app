import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:flutter/material.dart';

class AppLockToggle extends StatefulWidget {
  const AppLockToggle({super.key});

  @override
  State<AppLockToggle> createState() => _AppLockToggleState();
}

class _AppLockToggleState extends State<AppLockToggle> {
  final SecureStorage secureStorage = SecureStorage();
  bool enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value =
        await secureStorage.readSecureData("appLockEnabled");
    setState(() => enabled = value != "false");
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("App Lock"),
      subtitle:
          const Text("Secure app using phone lock"),
      value: enabled,
      onChanged: (value) async {
        setState(() => enabled = value);
        await secureStorage.writeSecureData(
          "appLockEnabled",
          value.toString(),
        );
      },
    );
  }
}
