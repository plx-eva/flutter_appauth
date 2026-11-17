#import "FlutterAppAuth.h"

@implementation FlutterAppAuth

+ (NSMutableDictionary *)processResponses:(OIDTokenResponse *)tokenResponse
                             authResponse:
                                 (OIDAuthorizationResponse *)authResponse {
  NSMutableDictionary *processedResponses = [[NSMutableDictionary alloc] init];
  if (tokenResponse.accessToken) {
    [processedResponses setValue:tokenResponse.accessToken
                          forKey:@"accessToken"];
  }
  if (tokenResponse.accessTokenExpirationDate) {
    [processedResponses
        setValue:[[NSNumber alloc]
                     initWithDouble:[tokenResponse.accessTokenExpirationDate
                                            timeIntervalSince1970] *
                                    1000]
          forKey:@"accessTokenExpirationTime"];
  }
  if (authResponse) {
    if (authResponse.additionalParameters) {
      [processedResponses setObject:authResponse.additionalParameters
                             forKey:@"authorizationAdditionalParameters"];
    }
    if (authResponse.request && authResponse.request.nonce) {
      [processedResponses setObject:authResponse.request.nonce forKey:@"nonce"];
    }
  }
  if (tokenResponse.additionalParameters) {
    [processedResponses setObject:tokenResponse.additionalParameters
                           forKey:@"tokenAdditionalParameters"];
  }
  if (tokenResponse.idToken) {
    [processedResponses setValue:tokenResponse.idToken forKey:@"idToken"];
  }
  if (tokenResponse.refreshToken) {
    [processedResponses setValue:tokenResponse.refreshToken
                          forKey:@"refreshToken"];
  }
  if (tokenResponse.tokenType) {
    [processedResponses setValue:tokenResponse.tokenType forKey:@"tokenType"];
  }
  if (tokenResponse.scope) {
    [processedResponses
        setObject:[tokenResponse.scope componentsSeparatedByString:@" "]
           forKey:@"scopes"];
  }

  return processedResponses;
}

+ (void)finishWithError:(NSString *)errorCode
                message:(NSString *)message
                 result:(FlutterResult)result
                  error:(NSError *_Nullable)error {

  NSMutableDictionary<NSString *, id> *details =
      [NSMutableDictionary dictionary];

  if (error) {
    id authError = error.userInfo[OIDOAuthErrorResponseErrorKey];
    NSDictionary<NSString *, id> *authErrorMap =
        [authError isKindOfClass:[NSDictionary class]] ? authError : nil;

    if (authErrorMap) {
      if ([authErrorMap objectForKey:OIDOAuthErrorFieldError]) {
        [details setObject:authErrorMap[OIDOAuthErrorFieldError]
                    forKey:OIDOAuthErrorFieldError];
      }
      if ([authErrorMap objectForKey:OIDOAuthErrorFieldErrorDescription]) {
        [details setObject:authErrorMap[OIDOAuthErrorFieldErrorDescription]
                    forKey:OIDOAuthErrorFieldErrorDescription];
      }
      if ([authErrorMap objectForKey:OIDOAuthErrorFieldErrorURI]) {
        [details setObject:authErrorMap[OIDOAuthErrorFieldErrorURI]
                    forKey:OIDOAuthErrorFieldErrorURI];
      }
    }
    if (error.domain) {
      [details setObject:error.domain forKey:@"type"];
    }
    if (error.code) {
      [details setObject:[@(error.code) stringValue] forKey:@"code"];
    }

    id underlyingErr = [error.userInfo objectForKey:NSUnderlyingErrorKey];
    NSError *underlyingError =
        [underlyingErr isKindOfClass:[NSError class]] ? underlyingErr : nil;
    if (underlyingError) {
      if (underlyingError.domain) {
        [details setObject:underlyingError.domain forKey:@"domain"];
      }

      if (underlyingError.debugDescription) {
        [details setObject:underlyingError.debugDescription
                    forKey:@"root_cause_debug_description"];
      }
    }

    if (error.debugDescription) {
      [details setObject:error.debugDescription
                  forKey:@"error_debug_description"];
    }

    // userInfo may contain values FlutterStandardMessageCodec cannot encode
    // (e.g. NSUnderlyingErrorKey -> NSError), which would trigger the codec's
    // "Unsupported value" assertion and abort the app. Only pass through
    // codec-safe values, converting the rest to their description.
    [error.userInfo
        enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
          details[[self codecSafeKey:key]] = [self codecSafeValue:value];
        }];

    bool userDidCancel =
        [error.domain isEqual:@"org.openid.appauth.general"] &&
        error.code == OIDErrorCodeUserCanceledAuthorizationFlow;
    [details setObject:(userDidCancel ? @"true" : @"false")
                forKey:@"user_did_cancel"];
  }
  result([FlutterError errorWithCode:errorCode
                             message:message
                             details:details]);
}

+ (NSString *)codecSafeKey:(id)key {
  return [key isKindOfClass:[NSString class]] ? key : [key description];
}

/// Returns a value FlutterStandardMessageCodec can encode: supported scalars
/// are returned as is, collections are sanitized recursively and any other
/// object (NSError, NSURL, NSDate, NSData...) is replaced by its description.
+ (id)codecSafeValue:(id)value {
  if (value == nil) {
    return [NSNull null];
  }
  if ([value isKindOfClass:[NSString class]] ||
      [value isKindOfClass:[NSNumber class]] ||
      [value isKindOfClass:[NSNull class]] ||
      [value isKindOfClass:[FlutterStandardTypedData class]]) {
    return value;
  }
  if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray *array =
        [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
    for (id item in (NSArray *)value) {
      [array addObject:[self codecSafeValue:item]];
    }
    return array;
  }
  if ([value isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *dictionary = [NSMutableDictionary
        dictionaryWithCapacity:[(NSDictionary *)value count]];
    [(NSDictionary *)value
        enumerateKeysAndObjectsUsingBlock:^(id key, id item, BOOL *stop) {
          dictionary[[self codecSafeKey:key]] = [self codecSafeValue:item];
        }];
    return dictionary;
  }
  return [value description] ?: [NSNull null];
}

+ (NSString *)formatMessageWithError:(NSString *)messageFormat
                               error:(NSError *_Nullable)error {
  NSString *formattedMessage =
      [NSString stringWithFormat:messageFormat, [error localizedDescription]];
  return formattedMessage;
}

@end

@implementation AppAuthAuthorization

- (id<OIDExternalUserAgentSession>)
    performAuthorization:(OIDServiceConfiguration *)serviceConfiguration
                clientId:(NSString *)clientId
            clientSecret:(NSString *)clientSecret
                  scopes:(NSArray *)scopes
             redirectUrl:(NSString *)redirectUrl
    additionalParameters:(NSDictionary *)additionalParameters
       externalUserAgent:(NSNumber *)externalUserAgent
                  result:(FlutterResult)result
            exchangeCode:(BOOL)exchangeCode
                   nonce:(NSString *)nonce {
  return nil;
}

- (id<OIDExternalUserAgentSession>)
    performEndSessionRequest:(OIDServiceConfiguration *)serviceConfiguration
           requestParameters:(EndSessionRequestParameters *)requestParameters
                      result:(FlutterResult)result {
  return nil;
}

- (void)failFlow:(id<OIDExternalUserAgentSession>)flow
       withError:(NSError *)error {
  id<OIDExternalUserAgent> externalUserAgent = self.currentExternalUserAgent;
  self.currentExternalUserAgent = nil;
  if (externalUserAgent) {
    [externalUserAgent
        dismissExternalUserAgentAnimated:YES
                              completion:^{
                                [flow failExternalUserAgentFlowWithError:error];
                              }];
  } else {
    [flow failExternalUserAgentFlowWithError:error];
  }
}

@end
