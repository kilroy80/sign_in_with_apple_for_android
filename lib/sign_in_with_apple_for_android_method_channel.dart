import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sign_in_with_apple_for_android/src/sign_in_apple_screen.dart';

import 'sign_in_with_apple_for_android.dart';
import 'sign_in_with_apple_for_android_platform_interface.dart';

/// An implementation of [SignInWithAppleForAndroidPlatform] that uses method channels.
class MethodChannelSignInWithAppleForAndroid extends SignInWithAppleForAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sign_in_with_apple_for_android');

  @override
  Future<String?> parseIntentData(String intent) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    final intentResult = await methodChannel.invokeMethod<String>(
      'parseIntentData',
      {
        'intent': intent,
      }
    );
    return intentResult;
  }

  @override
  Future<AuthorizationCredentialAppleID> signInApple(
    BuildContext context, WebAuthenticationOptions options, {
      String? userAgent,
      bool? appendUserAgent,
      String? state,
      String? nonce,
      SignInScheme? callbackScheme,
      Function(String schema)? onHandleScheme,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message:
        'parseAuthorizationCredentialAppleID: `authorizationCode` field was `null`',
      );
    }

    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        SignInAppleScreen(
          clientId: options.clientId,
          redirectUri: options.redirectUri.toString(),
          userAgent: userAgent,
          appendUserAgent: appendUserAgent,
          state: state,
          nonce: nonce,
          customScheme: callbackScheme?.scheme,
          customHost: callbackScheme?.host,
          onHandleScheme: onHandleScheme,
        ),
        opaque: false,
        barrierColor: Colors.transparent,
      ),
    );

    if (result is AuthorizationCredentialAppleID) {
      return result;
    } else {
      // return CredentialAppleParser().empty();
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message:
        'parseAuthorizationCredentialAppleID: `authorizationCode` field was `null`',
      );
    }
  }
}
