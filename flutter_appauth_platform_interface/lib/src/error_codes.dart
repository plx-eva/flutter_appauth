/// Unified, platform-agnostic error codes for the `flutter_appauth` plugin.
///
/// These are the possible values of [FlutterAppAuthPlatformException.errorCode]
/// and [FlutterAppAuthUserCancelledException.errorCode].
///
/// Codes are grouped into three categories:
/// - **Operation codes**: what the plugin was doing when the error occurred.
/// - **AppAuth SDK cause codes**: what the underlying AppAuth SDK reported.
/// - **OAuth error codes**: error strings returned by the authorization server
///   (matching RFC 6749 lowercase strings).
class FlutterAppAuthErrorCode {
  // ── Operation codes ───────────────────────────────────────────────────────
  static const String discoveryFailed = 'discovery_failed';
  static const String authorizeAndExchangeCodeFailed =
      'authorize_and_exchange_code_failed';
  static const String authorizeFailed = 'authorize_failed';
  static const String tokenFailed = 'token_failed';
  static const String endSessionFailed = 'end_session_failed';

  /// Android only.
  static const String nullIntent = 'null_intent';

  /// Android only.
  static const String invalidClaims = 'invalid_claims';

  /// Android only.
  static const String noBrowserAvailable = 'no_browser_available';

  // ── AppAuth SDK cause codes ───────────────────────────────────────────────
  static const String invalidDiscoveryDocument = 'invalid_discovery_document';
  static const String userCancelled = 'user_cancelled';
  static const String programCancelled = 'program_cancelled';
  static const String networkError = 'network_error';
  static const String appAuthServerError = 'appauth_server_error';
  static const String jsonDeserializationError = 'json_deserialization_error';
  static const String tokenResponseConstructionError =
      'token_response_construction_error';

  /// macOS only (NSWorkspace.openURL returned NO).
  static const String browserOpenError = 'browser_open_error';

  /// iOS only.
  static const String tokenRefreshError = 'token_refresh_error';
  static const String invalidRegistrationResponse =
      'invalid_registration_response';

  /// iOS only.
  static const String jsonSerializationError = 'json_serialization_error';
  static const String idTokenParsingError = 'id_token_parsing_error';
  static const String idTokenValidationError = 'id_token_validation_error';

  // ── OAuth error codes (from authorization server, per RFC 6749) ───────────
  static const String oauthInvalidRequest = 'invalid_request';
  static const String oauthUnauthorizedClient = 'unauthorized_client';
  static const String oauthAccessDenied = 'access_denied';
  static const String oauthUnsupportedResponseType =
      'unsupported_response_type';
  static const String oauthInvalidScope = 'invalid_scope';
  static const String oauthServerError = 'server_error';
  static const String oauthTemporarilyUnavailable = 'temporarily_unavailable';
  static const String oauthInvalidClient = 'invalid_client';
  static const String oauthInvalidGrant = 'invalid_grant';
  static const String oauthUnsupportedGrantType = 'unsupported_grant_type';
  static const String oauthInvalidRedirectUri = 'invalid_redirect_uri';
  static const String oauthInvalidClientMetadata = 'invalid_client_metadata';
}
