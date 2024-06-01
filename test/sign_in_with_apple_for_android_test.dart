import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sign_in_with_apple_for_android/sign_in_with_apple_for_android.dart';
import 'package:sign_in_with_apple_for_android/sign_in_with_apple_for_android_platform_interface.dart';
import 'package:sign_in_with_apple_for_android/sign_in_with_apple_for_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sign_in_with_apple_for_android/src/credential_apple_parser.dart';

class MockSignInWithAppleForAndroidPlatform
    with MockPlatformInterfaceMixin
    implements SignInWithAppleForAndroidPlatform {

  @override
  Future<String?> parseIntentData(String intent) => Future.value('scheme');

  @override
  Future<AuthorizationCredentialAppleID> signInApple(
    BuildContext context, WebAuthenticationOptions options, {
      String? userAgent,
      bool? appendUserAgent,
      String? state,
      String? nonce,
      SignInScheme? callbackScheme,
      Function(String scheme)? onHandleScheme,
  }) async {
    return CredentialAppleParser().empty();
  }
}

void main() {
  final SignInWithAppleForAndroidPlatform initialPlatform = SignInWithAppleForAndroidPlatform.instance;

  test('$MethodChannelSignInWithAppleForAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSignInWithAppleForAndroid>());
  });
}
