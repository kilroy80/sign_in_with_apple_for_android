import 'dart:convert';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class CredentialAppleParser {

  AuthorizationCredentialAppleID parseAuthorizationCredentialAppleIDFromDeeplink(
      Uri deeplink,
      ) {
    if (deeplink.queryParameters.containsKey('error')) {
      /// In case an error occured during the web flow, the URL will have an `error` parameter.
      ///
      /// The only error code that might be returned is `user_cancelled_authorize`,
      /// which indicates that the user clicked the `Cancel` button during the web flow.
      ///
      /// https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms
      if (deeplink.queryParameters['error'] == 'user_cancelled_authorize') {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'User canceled authorization',
        );
      }
    }

    final user = deeplink.queryParameters.containsKey('user')
        ? json.decode(deeplink.queryParameters['user'] as String)
    as Map<String, dynamic>
        : null;
    final name = user != null ? user['name'] as Map<String, dynamic>? : null;

    final authorizationCode = deeplink.queryParameters['code'];
    if (authorizationCode == null) {
      throw const SignInWithAppleAuthorizationException(
        code: AuthorizationErrorCode.invalidResponse,
        message:
        'parseAuthorizationCredentialAppleIDFromDeeplink: No `code` query parameter set)',
      );
    }

    return AuthorizationCredentialAppleID(
      authorizationCode: authorizationCode,
      email: user?['email'] as String?,
      givenName: name?['firstName'] as String?,
      familyName: name?['lastName'] as String?,
      userIdentifier: null,
      identityToken: deeplink.queryParameters['id_token'],
      state: deeplink.queryParameters['state'],
    );
  }

  AuthorizationCredentialAppleID empty() {
    return const AuthorizationCredentialAppleID(
      userIdentifier: null,
      authorizationCode: '',
      givenName: null,
      familyName: null,
      email: null,
      identityToken: null,
      state: null,
    );
  }
}