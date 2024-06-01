import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'sign_in_with_apple_for_android.dart';
import 'sign_in_with_apple_for_android_method_channel.dart';

abstract class SignInWithAppleForAndroidPlatform extends PlatformInterface {
  /// Constructs a SignInWithAppleForAndroidPlatform.
  SignInWithAppleForAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static SignInWithAppleForAndroidPlatform _instance = MethodChannelSignInWithAppleForAndroid();

  /// The default instance of [SignInWithAppleForAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelSignInWithAppleForAndroid].
  static SignInWithAppleForAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SignInWithAppleForAndroidPlatform] when
  /// they register themselves.
  static set instance(SignInWithAppleForAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> parseIntentData(String intent) {
    throw UnimplementedError('parseIntentData() has not been implemented.');
  }

  Future<AuthorizationCredentialAppleID> signInApple(
    BuildContext context, WebAuthenticationOptions options, {
      String? userAgent,
      bool? appendUserAgent,
      String? state,
      String? nonce,
      SignInScheme? callbackScheme,
      Function(String scheme)? onHandleScheme,
  }) {
    throw UnimplementedError('signInApple() has not been implemented.');
  }
}
