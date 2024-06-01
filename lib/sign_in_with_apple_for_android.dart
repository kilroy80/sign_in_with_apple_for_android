import 'package:flutter/widgets.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'sign_in_with_apple_for_android_platform_interface.dart';

class SignInWithAppleForAndroid {

  Future<String?> parseIntentData(String intent) {
    return SignInWithAppleForAndroidPlatform.instance.parseIntentData(intent);
  }

  Future<AuthorizationCredentialAppleID> signInApple(
    BuildContext context, WebAuthenticationOptions options, {
      String? userAgent,
      bool? appendUserAgent,
      String? state,
      String? nonce,
      SignInScheme? callbackScheme,
      Function(String scheme)? onHandleScheme,
  }) async {
    return await SignInWithAppleForAndroidPlatform.instance.signInApple(
      context, options,
      userAgent: userAgent, appendUserAgent: appendUserAgent,
      state: state, nonce: nonce,
      callbackScheme: callbackScheme, onHandleScheme: onHandleScheme,
    );
  }
}

class SignInScheme {
  SignInScheme({
    required this.scheme,
    required this.host,
  });

  final String scheme;
  final String host;
}
