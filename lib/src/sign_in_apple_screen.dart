import 'package:material_ui/material_ui.dart';
import 'package:sign_in_with_apple_for_android/src/credential_apple_parser.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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

  late final WebViewController _controller;
  late Uri openUri;

  @override
  void initState() {
    super.initState();

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

    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        /// iOS media playback auto play = empty array
        mediaTypesRequiringUserAction: const {
        },
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
          },
          onPageFinished: (String url) {
          },
          onProgress: (progress) {
            if (progress > 50 && initProgressIndicator == true) {
              setState(() {
                initProgressIndicator = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web Resource Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            var actionUrl = Uri.parse(request.url);
            debugPrint('onNavigationRequest = $actionUrl');

            if (actionUrl.scheme == 'http' || actionUrl.scheme == 'https') {
              return NavigationDecision.navigate;
            } else if (actionUrl.scheme == 'intent') {
              /// android only
              /// Intent.parseUri(uriString, Intent.URI_INTENT_SCHEME)
              /// and Handle Custom Scheme
              var intentData = await SignInWithAppleForAndroid()
                  .parseIntentData(actionUrl.toString()) ?? '';
              parseCustomScheme(Uri.parse(intentData));
              return NavigationDecision.prevent;
            } else {
              parseCustomScheme(actionUrl);
              return NavigationDecision.prevent;
            }
          },
        ),
      );

    if (_controller.platform is AndroidWebViewController) {
      /// android debug
      // AndroidWebViewController.enableDebugging(true);

      /// android media playback auto play (false)
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);

      /// android permission
      (_controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest(
            (PlatformWebViewPermissionRequest request) {
          request.grant();
        },
      );
      /// android geolocation permissions
      (_controller.platform as AndroidWebViewController)
          .setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (GeolocationPermissionsRequestParams request) async {
          return const GeolocationPermissionsResponse(
            allow: true,
            retain: false,
          );
        },
        onHidePrompt: () {
        },
      );
    }

    /// async call function
    addSettingAndLoadUrl();
  }

  Future<void> addSettingAndLoadUrl() async {
    /// set User Agent
    if (widget.userAgent?.isNotEmpty == true) {
      if (widget.appendUserAgent == true) {
        final String? defaultUserAgent = await _controller.getUserAgent();
        _controller.setUserAgent('$defaultUserAgent ${widget.userAgent}');
      } else {
        _controller.setUserAgent(widget.userAgent);
      }
    }
    /// load page
    _controller.loadRequest(openUri);
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
              child: WebViewWidget(controller: _controller),
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
    if (uri.scheme != widget.customScheme || uri.host != widget.customHost) {
      widget.onHandleScheme?.call(uri.toString());
    }

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
