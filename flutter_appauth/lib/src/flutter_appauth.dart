import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';

class FlutterAppAuth {
  const FlutterAppAuth();

  /// Convenience method for authorizing and then exchanges code
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
    AuthorizationTokenRequest request,
  ) {
    return FlutterAppAuthPlatform.instance.authorizeAndExchangeCode(request);
  }

  /// Sends an authorization request.
  ///
  /// This is done by sending a request to the authorization server's
  /// [authorization endpoint](https://datatracker.ietf.org/doc/html/rfc6749#section-3.1).
  Future<AuthorizationResponse> authorize(AuthorizationRequest request) {
    return FlutterAppAuthPlatform.instance.authorize(request);
  }

  /// For exchanging tokens.
  ///
  /// This is done by sending a request to the authorization server's
  /// [token endpoint](https://datatracker.ietf.org/doc/html/rfc6749#section-3.2).
  Future<TokenResponse> token(TokenRequest request) {
    return FlutterAppAuthPlatform.instance.token(request);
  }

  /// Performs an end session/logout request.
  ///
  /// This is done by sending a request to the authorization server's
  /// end session endpoint per the [RP-initiated logout spec](https://openid.net/specs/openid-connect-rpinitiated-1_0.html).
  Future<EndSessionResponse> endSession(EndSessionRequest request) {
    return FlutterAppAuthPlatform.instance.endSession(request);
  }

  /// Fails the in-flight authorize/end session request (if any), dismissing the
  /// browser/Custom Tab or `ASWebAuthenticationSession`/`SFSafariViewController`
  /// it opened.
  ///
  /// Useful when a redirect is delivered through a channel that bypasses the
  /// plugin's normal redirect handling (e.g. a universal/app link received
  /// directly by the host app), which would otherwise leave the browser open
  /// indefinitely.
  ///
  /// [errorDetails] is exposed through the resulting
  /// [PlatformException.details] value.
  Future<void> failCurrentFlow({
    String? errorCode,
    String? errorMessage,
    Map<String, dynamic>? errorDetails,
  }) {
    return FlutterAppAuthPlatform.instance.failCurrentFlow(
      errorCode: errorCode,
      errorMessage: errorMessage,
      errorDetails: errorDetails,
    );
  }
}
