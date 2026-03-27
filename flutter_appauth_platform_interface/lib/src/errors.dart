import 'package:flutter/services.dart';

import 'error_codes.dart';

/// The details of an error thrown from the underlying
/// platform's AppAuth SDK
class FlutterAppAuthPlatformErrorDetails {
  FlutterAppAuthPlatformErrorDetails({
    this.type,
    this.code,
    this.error,
    this.errorDescription,
    this.errorUri,
    this.domain,
    this.rootCauseDebugDescription,
    this.errorDebugDescription,
  });

  /// The type of error.
  ///
  /// On iOS/macOS: one of the domain values from [here](https://github.com/openid/AppAuth-iOS/blob/c89ed571ae140f8eb1142735e6e23d7bb8c34cb2/Sources/AppAuthCore/OIDError.m#L31).
  /// On Android: one of the type codes from [here](https://github.com/openid/AppAuth-Android/blob/c6137b7db306d9c097c0d5763f3fb944cd0122d2/library/java/net/openid/appauth/AuthorizationException.java).
  ///
  /// It's recommended to not use this unless needed. In most cases, errors
  /// can be handled using the [error] property.
  final String? type;

  /// An error code from the platform's AppAuth SDK.
  ///
  /// On iOS/macOS: depending on the error type, it will be values from [here](https://github.com/openid/AppAuth-iOS/blob/c89ed571ae140f8eb1142735e6e23d7bb8c34cb2/Sources/AppAuthCore/OIDError.h).
  /// On Android: one of the codes defined [here](https://github.com/openid/AppAuth-Android/blob/c6137b7db306d9c097c0d5763f3fb944cd0122d2/library/java/net/openid/appauth/AuthorizationException.java#L158).
  ///
  /// This is the low-level native AppAuth SDK code and is distinct from the
  /// unified [FlutterAppAuthErrorCode] constants. Use
  /// [FlutterAppAuthPlatformException.errorCode] for platform-agnostic error
  /// handling.
  ///
  /// It's recommended to not use this unless needed. In most cases, errors
  /// can be handled using the [error] property.
  final String? code;

  /// Error from the authorization server.
  ///
  /// For 400 errors from the authorization server, this is corresponds to the
  /// `error` parameter as defined in the OAuth 2.0 framework [here](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2).
  /// Otherwise a short error describing what happened.
  ///
  /// The [FlutterAppAuthOAuthError] class contains string constants for
  /// the standard error codes that could used by applications to determine the
  /// nature of the error.
  ///
  /// Note that authorization servers may return custom error codes that are not
  /// defined in the OAuth 2.0 framework.
  final String? error;

  /// Short, human readable error description.
  ///
  /// This may come from the authhorization server that it correspond to the
  /// `error_description` parameter as defined in the OAuth
  /// 2.0 [here](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2).
  /// Otherwise, this is populated by the underlying platform's AppAuth SDK.
  final String? errorDescription;

  /// Error URI from the authorization server.
  ///
  /// Corresponds to the `error_uri` parameter defined in the OAuth 2.0
  /// framework [here](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2)
  final String? errorUri;

  /// Error domain from the AppAuth iOS SDK.
  ///
  /// Only populated on iOS/macOS.
  final String? domain;

  /// A debug description of the error from the platform's AppAuth SDK
  final String? errorDebugDescription;

  /// A debug description of the underlying cause of the error from the
  /// platform's AppAuth SDK
  final String? rootCauseDebugDescription;

  @override
  String toString() {
    return 'FlutterAppAuthPlatformErrorDetails(type: $type,\n code: $code,\n '
        'error: $error,\n errorDescription: $errorDescription,\n '
        'errorUri: $errorUri,\n domain $domain,\n'
        'rootCauseDebugDescription: $rootCauseDebugDescription,\n '
        'errorDebugDescription: $errorDebugDescription)';
  }

  static FlutterAppAuthPlatformErrorDetails fromMap(Map<String?, String?> map) {
    return FlutterAppAuthPlatformErrorDetails(
      type: map['type'],
      code: map['code'],
      error: map['error'],
      errorDescription: map['error_description'],
      errorUri: map['error_uri'],
      domain: map['domain'],
      rootCauseDebugDescription: map['root_cause_debug_description'],
      errorDebugDescription: map['error_debug_description'],
    );
  }
}

/// Thrown when an authorization request has been cancelled as a result of a
/// user closing the browser.
class FlutterAppAuthUserCancelledException extends PlatformException {
  FlutterAppAuthUserCancelledException({
    required super.code,
    super.message,
    dynamic legacyDetails,
    super.stacktrace,
    required this.platformErrorDetails,
  }) : super(details: legacyDetails);

  /// Details of the error from the underlying platform's AppAuth SDK.
  final FlutterAppAuthPlatformErrorDetails platformErrorDetails;

  /// Always returns [FlutterAppAuthErrorCode.userCancelled].
  ///
  /// Catching [FlutterAppAuthUserCancelledException] itself is the primary
  /// way to handle user cancellation; this property is provided for parity
  /// with [FlutterAppAuthPlatformException.errorCode].
  String get errorCode => FlutterAppAuthErrorCode.userCancelled;

  @override
  String toString() {
    return 'FlutterAppAuthUserCancelledException{platformErrorDetails: '
        '$platformErrorDetails}';
  }
}

/// Thrown to indicate an interaction failed in the `package:flutter_appauth`
/// plugin.
class FlutterAppAuthPlatformException extends PlatformException {
  FlutterAppAuthPlatformException({
    required super.code,
    super.message,
    dynamic legacyDetails,
    super.stacktrace,
    required this.platformErrorDetails,
  }) : super(details: legacyDetails);

  /// Details of the error from the underlying platform's AppAuth SDK.
  final FlutterAppAuthPlatformErrorDetails platformErrorDetails;

  /// A unified, platform-agnostic error code.
  ///
  /// Use [FlutterAppAuthErrorCode] constants to match against this value:
  /// ```dart
  /// } on FlutterAppAuthPlatformException catch (e) {
  ///   switch (e.errorCode) {
  ///     case FlutterAppAuthErrorCode.networkError:
  ///       // handle network error
  ///     case FlutterAppAuthErrorCode.tokenFailed:
  ///       // token operation failed for an unmapped reason
  ///   }
  /// }
  /// ```
  ///
  /// Resolution order:
  /// 1. If the server returned an OAuth error string (e.g. `invalid_grant`),
  ///    that string is returned directly — match it against
  ///    [FlutterAppAuthErrorCode.oauthInvalidGrant] etc.
  /// 2. If the native AppAuth SDK code maps to a known cause, the cause
  ///    code is returned (e.g. [FlutterAppAuthErrorCode.networkError]).
  /// 3. Falls back to the operation code from [PlatformException.code]
  ///    (e.g. [FlutterAppAuthErrorCode.tokenFailed]).
  String get errorCode => _resolveErrorCode(platformErrorDetails, code);
}

/// Represents OAuth error codes that can be returned by the authorization
/// server.
///
/// These are the standard error codes defined in the OAuth 2.0 framework
/// [here](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2).
class FlutterAppAuthOAuthError {
  static const String invalidRequest = 'invalid_request';
  static const String invalidClient = 'invalid_client';
  static const String invalidGrant = 'invalid_grant';
  static const String unauthorizedClient = 'unauthorized_client';
  static const String unsupportedGrantType = 'unsupported_grant_type';
  static const String invalidScope = 'invalid_scope';
}

String _resolveErrorCode(
  FlutterAppAuthPlatformErrorDetails details,
  String fallback,
) {
  // 1. OAuth error string from server matches constants directly
  final oauthError = details.error;
  if (oauthError != null) return oauthError;

  final nativeCode = int.tryParse(details.code ?? '');
  if (nativeCode == null) return fallback;

  final type = details.type;
  if (type == null) return fallback;

  // Android: type is a small integer string ("0" = general errors)
  final androidType = int.tryParse(type);
  if (androidType != null) {
    if (androidType == 0) {
      return _androidGeneralCode(nativeCode) ?? fallback;
    }
    return fallback;
  }

  // iOS/macOS: type is the NSError domain string
  if (type == 'org.openid.appauth.general') {
    return _iosGeneralCode(nativeCode) ?? fallback;
  }
  return fallback;
}

String? _androidGeneralCode(int code) => switch (code) {
  0 => FlutterAppAuthErrorCode.invalidDiscoveryDocument,
  1 => FlutterAppAuthErrorCode.userCancelled,
  2 => FlutterAppAuthErrorCode.programCancelled,
  3 => FlutterAppAuthErrorCode.networkError,
  4 => FlutterAppAuthErrorCode.appAuthServerError,
  5 => FlutterAppAuthErrorCode.jsonDeserializationError,
  6 => FlutterAppAuthErrorCode.tokenResponseConstructionError,
  7 => FlutterAppAuthErrorCode.invalidRegistrationResponse,
  8 => FlutterAppAuthErrorCode.idTokenParsingError,
  9 => FlutterAppAuthErrorCode.idTokenValidationError,
  _ => null,
};

String? _iosGeneralCode(int code) => switch (code) {
  -2 => FlutterAppAuthErrorCode.invalidDiscoveryDocument,
  -3 => FlutterAppAuthErrorCode.userCancelled,
  -4 => FlutterAppAuthErrorCode.programCancelled,
  -5 => FlutterAppAuthErrorCode.networkError,
  -6 => FlutterAppAuthErrorCode.appAuthServerError,
  -7 => FlutterAppAuthErrorCode.jsonDeserializationError,
  -8 => FlutterAppAuthErrorCode.tokenResponseConstructionError,
  -9 => FlutterAppAuthErrorCode.browserOpenError,
  -10 => FlutterAppAuthErrorCode.browserOpenError,
  -11 => FlutterAppAuthErrorCode.tokenRefreshError,
  -12 => FlutterAppAuthErrorCode.invalidRegistrationResponse,
  -13 => FlutterAppAuthErrorCode.jsonSerializationError,
  -14 => FlutterAppAuthErrorCode.idTokenParsingError,
  -15 => FlutterAppAuthErrorCode.idTokenValidationError,
  _ => null,
};
