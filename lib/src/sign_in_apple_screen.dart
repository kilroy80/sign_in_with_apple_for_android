import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sign_in_with_apple_for_android/src/credential_apple_parser.dart';

import '../sign_in_with_apple_for_android.dart';

class SignInAppleScreen extends StatefulWidget {
  const SignInAppleScreen({
    super.key,
    required this.clientId,
    required this.redirectUri,
    this.onHandleScheme,
    this.userAgent = '',
    this.appendUserAgent = true,
    this.state,
    this.nonce,
    this.customScheme = 'signinwithapple',
    this.customHost = 'callback',
    this.useHybridComposition = false,
  });

  final String clientId;
  final String redirectUri;

  final String? userAgent;
  final bool? appendUserAgent;
  final String? state;
  final String? nonce;

  final Function(String schema)? onHandleScheme;

  final String? customScheme;
  final String? customHost;

  final bool? useHybridComposition;

  @override
  State<SignInAppleScreen> createState() => _SignInAppleScreenState();
}

class _SignInAppleScreenState extends State<SignInAppleScreen> {

  var initProgressIndicator = true;

  late Uri openUri;
  late InAppWebViewSettings settings;

  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();

    settings = widget.appendUserAgent == false ? InAppWebViewSettings(
      userAgent: widget.userAgent,
      useShouldOverrideUrlLoading: true,
      useHybridComposition: widget.useHybridComposition,  // impeller enabled = true, otherwise = false
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    ) : InAppWebViewSettings(
      applicationNameForUserAgent: widget.userAgent,
      useShouldOverrideUrlLoading: true,
      useHybridComposition: widget.useHybridComposition,  // impeller enabled = true, otherwise = false
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    );

    openUri = Uri(
      scheme: 'https',
      host: 'appleid.apple.com',
      path: 'auth/authorize',
      queryParameters: {
        'response_type': 'code id_token',
        'client_id': widget.clientId,
        'redirect_uri': widget.redirectUri,
        'scope': 'name email',
        'response_mode': 'form_post',
        if (widget.state != null) 'state': widget.state,
        if (widget.nonce != null) 'nonce': widget.nonce,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          height: kToolbarHeight,
          color: Colors.transparent,
          alignment: Alignment.center,
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0,),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0,),
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(openUri.toString()),),
                initialSettings: settings,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  if (progress > 50 && initProgressIndicator == true) {
                    setState(() {
                      initProgressIndicator = false;
                    });
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var actionUrl = navigationAction.request.url ?? Uri.parse('');
                  debugPrint('shouldOverrideUrlLoading = $actionUrl');

                  if (actionUrl.scheme == 'http' || actionUrl.scheme == 'https') {
                    return NavigationActionPolicy.ALLOW;
                  } else if (actionUrl.scheme == 'intent') {
                    /// android only
                    /// Intent.parseUri(uriString, Intent.URI_INTENT_SCHEME)
                    /// and Handle Custom Scheme
                    var intentData = await SignInWithAppleForAndroid()
                        .parseIntentData(actionUrl.toString()) ?? '';
                    parseCustomScheme(Uri.parse(intentData));
                    return NavigationActionPolicy.CANCEL;
                  } else {
                    parseCustomScheme(actionUrl);
                    return NavigationActionPolicy.CANCEL;
                  }

                  // if (await canLaunchUrl(actionUrl)) {
                  //   return NavigationActionPolicy.ALLOW;
                  // } else {
                  //   return NavigationActionPolicy.CANCEL;
                  // }
                },
                onTitleChanged: (InAppWebViewController controller, String? title) {
                },
                onPermissionRequest:
                    (InAppWebViewController controller, PermissionRequest request) async {
                  return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT);
                },
                // onGeolocationPermissionsShowPrompt:
                //     (InAppWebViewController controller, String origin) async {
                //   return GeolocationPermissionShowPromptResponse(
                //     origin: origin,
                //     allow: true,
                //     retain: true,
                //   );
                // },
              ),
            ),
          ),
          Visibility(
            visible: initProgressIndicator,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  void parseCustomScheme(Uri uri) {

    if (uri.host != widget.customHost) widget.onHandleScheme?.call(uri.toString());
    if (uri.query.isNotEmpty) {
      try {
        // debugPrint('uri query == ${Uri.decodeComponent(uri.query)}');
        // debugPrint('uri query == ${uri.queryParameters}');
        // var data = jsonDecode(Uri.decodeComponent(uri.query));

        var apple = CredentialAppleParser().parseAuthorizationCredentialAppleIDFromDeeplink(
          uri,
        );
        Navigator.pop(context, apple);
      } catch (e) {
        Navigator.pop(context);
      }
    }
  }
}
