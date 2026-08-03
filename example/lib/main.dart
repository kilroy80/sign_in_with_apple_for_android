import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:sign_in_with_apple_for_android/sign_in_with_apple_for_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final _signInWithAppleForAndroidPlugin = SignInWithAppleForAndroid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: MaterialButton(
          onPressed: () async {
            try {
              await _signInWithAppleForAndroidPlugin.signInApple(
                context,
                WebAuthenticationOptions(
                  clientId: 'ios service id',
                  redirectUri: Uri.parse('ios callback url'),
                ),
                userAgent: 'Sample',
                callbackScheme: SignInScheme(scheme: 'scheme', host: 'host'),
              );
            } catch (e) {
              debugPrint('signInApple error = $e');
            }
          },
          child: const Center(
            child: Text('Open Apple Sign-In View'),
          ),
        ),
      ),
    );
  }
}
