/*
 * Copyright 2018 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <TargetConditionals.h>
#if TARGET_OS_IOS

#import "FirebaseDynamicLinks/Sources/Public/FirebaseDynamicLinks/FIRDynamicLinks.h"

#import <UIKit/UIKit.h>

#ifdef FIRDynamicLinks3P
#import "FirebaseCore/Sources/Private/FirebaseCoreInternal.h"
#import "FirebaseDynamicLinks/Sources/FIRDLScionLogging.h"
#import "Interop/Analytics/Public/FIRAnalyticsInterop.h"
#else
#import "FirebaseCore/Sources/Public/FirebaseCore/FIRVersion.h"
#endif

#ifdef FIRDynamicLinks3P
#import "FirebaseDynamicLinks/Sources/FDLURLComponents/FDLURLComponents+Private.h"
#endif
#import "FirebaseDynamicLinks/Sources/FIRDLRetrievalProcessFactory.h"
#import "FirebaseDynamicLinks/Sources/FIRDLRetrievalProcessProtocols.h"
#import "FirebaseDynamicLinks/Sources/FIRDLRetrievalProcessResult.h"
#import "FirebaseDynamicLinks/Sources/FIRDynamicLink+Private.h"
#import "FirebaseDynamicLinks/Sources/FIRDynamicLinkNetworking.h"
#import "FirebaseDynamicLinks/Sources/FIRDynamicLinks+FirstParty.h"
#import "FirebaseDynamicLinks/Sources/FIRDynamicLinks+Private.h"
#import "FirebaseDynamicLinks/Sources/Logging/FDLLogging.h"
#import "FirebaseDynamicLinks/Sources/Utilities/FDLUtilities.h"

// We should only read the deeplink after install once. We use the following key to store the state
// in the user defaults.
NSString *const kFIRDLReadDeepLinkAfterInstallKey =
    @"com.google.appinvite.readDeeplinkAfterInstall";

// We should only open url once. We use the following key to store the state in the user defaults.
static NSString *const kFIRDLOpenURLKey = @"com.google.appinvite.openURL";

// Custom domains to be allowed are optionally added as an array to the info.plist.
static NSString *const kInfoPlistCustomDomainsKey = @"FirebaseDynamicLinksCustomDomains";

NS_ASSUME_NONNULL_BEGIN

@interface FIRDynamicLinks () <FIRDLRetrievalProcessDelegate>

// API Key for API access.
@property(nonatomic, copy) NSString *APIKey;

// Custom URL scheme.
@property(nonatomic, copy) NSString *URLScheme;

// Networking object for Dynamic Links
@property(nonatomic, readonly) FIRDynamicLinkNetworking *dynamicLinkNetworking;

@property(atomic, assign) BOOL retrievingPendingDynamicLink;

@end

#ifdef FIRDynamicLinks3P
// Error code from FDL.
static const NSInteger FIRErrorCodeDurableDeepLinkFailed = -119;

@interface FIRDynamicLinks () {
  /// Stored Analytics reference, if it exists.
  id<FIRAnalyticsInterop> _Nullable _analytics;
}
@end

// DynamicLinks doesn't provide any functionality to other components,
// so it provides a private, empty protocol that it conforms to and use it for registration.

@protocol FIRDynamicLinksInstanceProvider
@end

@interface FIRDynamicLinks () <FIRDynamicLinksInstanceProvider, FIRLibrary>

@end

#endif

@implementation FIRDynamicLinks {
  // User defaults passed.
  NSUserDefaults *_userDefaults;

  FIRDynamicLinkNetworking *_dynamicLinkNetworking;

  id<FIRDLRetrievalProcessProtocol> _retrievalProcess;
}

#pragma mark - Object lifecycle

#ifdef FIRDynamicLinks3P

+ (void)load {
  [FIRApp registerInternalLibrary:self withName:@"fire-dl"];
}

+ (nonnull NSArray<FIRComponent *> *)componentsToRegister {
  // Product requirement is enforced by CocoaPod. Not technical requirement for analytics.
  FIRDependency *analyticsDep = [FIRDependency dependencyWithProtocol:@protocol(FIRAnalyticsInterop)
                                                           isRequired:NO];
  FIRComponentCreationBlock creationBlock =
      ^id _Nullable(FIRComponentContainer *container, BOOL *isCacheable) {
    // Don't return an instance when it's not the default app.
    if (!container.app.isDefaultApp) {
      // Only configure for the default FIRApp.
      FDLLog(FDLLogLevelInfo, FDLLogIdentifierSetupNonDefaultApp,
             @"Firebase Dynamic Links only "
              "works with the default app.");
      return nil;
    }

    // Ensure it's cached so it returns the same instance every time dynamicLinks is called.
    *isCacheable = YES;
    id<FIRAnalyticsInterop> analytics = FIR_COMPONENT(FIRAnalyticsInterop, container);
    FIRDynamicLinks *dynamicLinks = [[FIRDynamicLinks alloc] initWithAnalytics:analytics];
    [dynamicLinks configureDynamicLinks:container.app];
    // Check for pending Dynamic Link automatically if enabled, otherwise we expect the developer to
    // call strong match FDL API to retrieve a pending link.
    if ([FIRDynamicLinks isAutomaticRetrievalEnabled]) {
      [dynamicLinks checkForPendingDynamicLink];
    }
    return dynamicLinks;
  };
  FIRComponent *dynamicLinksProvider =
      [FIRComponent componentWithProtocol:@protocol(FIRDynamicLinksInstanceProvider)
                      instantiationTiming:FIRInstantiationTimingEagerInDefaultApp
                             dependencies:@[ analyticsDep ]
                            creationBlock:creationBlock];

  return @[ dynamicLinksProvider ];
}

- (void)configureDynamicLinks:(FIRApp *)app {
  FIROptions *options = app.options;
  NSError *error;
  NSMutableString *errorDescription;
  NSString *urlScheme;

  if (options.APIKey.length == 0) {
    errorDescription = [@"API key must not be nil or empty." mutableCopy];
  }

  if (!errorDescription) {
    // setup FDL if no error detected
    urlScheme = options.deepLinkURLScheme ?: [NSBundle mainBundle].bundleIdentifier;
    [self setUpWithLaunchOptions:nil apiKey:options.APIKey urlScheme:urlScheme userDefaults:nil];
  } else {
    NSString *description =
        [NSString stringWithFormat:@"Configuration failed for service DynamicLinks."];
    NSDictionary *errorDict = @{
      NSLocalizedDescriptionKey : description,
      NSLocalizedFailureReasonErrorKey : errorDescription
    };
    error = [NSError errorWithDomain:kFirebaseDurableDeepLinkErrorDomain
                                code:FIRErrorCodeDurableDeepLinkFailed
                            userInfo:errorDict];
  }
  if (error) {
    NSString *message = nil;
    if (options.usingOptionsFromDefaultPlist) {
      // Configured using plist file
      message = [NSString
          stringWithFormat:
              @"Firebase Dynamic Links has stopped your project "
              @"because there are missing or incorrect values provided in %@.%@ that may "
              @"prevent your app from behaving as expected:\n\n"
              @"Error: %@\n\n"
              @"Please fix these issues to ensure that Firebase is correctly configured in "
              @"your project.",
              kServiceInfoFileName, kServiceInfoFileType, error.localizedFailureReason];
    } else {
      // Configured manually
      message = [NSString
          stringWithFormat:
              @"Firebase Dynamic Links has stopped your project "
              @"because there are incorrect values provided in Firebase's configuration "
              @"options that may prevent your app from behaving as expected:\n\n"
              @"Error: %@\n\n"
              @"Please fix these issues to ensure that Firebase is correctly configured in "
              @"your project.",
              error.localizedFailureReason];
    }
    [NSException raise:kFirebaseDurableDeepLinkErrorDomain format:@"%@", message];
  }
  [self checkForCustomDomainEntriesInInfoPlist];
}

- (instancetype)initWithAnalytics:(nullable id<FIRAnalyticsInterop>)analytics {
  self = [super init];
  if (self) {
    _analytics = analytics;
  }
  return self;
}

+ (instancetype)dynamicLinks {
  FIRApp *defaultApp = [FIRApp defaultApp];  // Missing configure will be logged here.
  id<FIRDynamicLinksInstanceProvider> instance =
      FIR_COMPONENT(FIRDynamicLinksInstanceProvider, defaultApp.container);
  return (FIRDynamicLinks *)instance;
}

#else
+ (instancetype)dynamicLinks {
  static FIRDynamicLinks *dynamicLinks;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dynamicLinks = [[self alloc] init];
  });
  return dynamicLinks;
}
#endif

#pragma mark - Custom domains

- (instancetype)init {
  self = [super init];
  if (self) {
    [self checkForCustomDomainEntriesInInfoPlist];
  }
  return self;
}

// Check for custom domains entry in PLIST file.
- (void)checkForCustomDomainEntriesInInfoPlist {
  // Check to see if FirebaseDynamicLinksCustomDomains array is present.
  NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
  NSArray *customDomains = infoDictionary[kInfoPlistCustomDomainsKey];
  if (customDomains) {
    FIRDLAddToAllowListForCustomDomainsArray(customDomains);
  }
}

#pragma mark - First party interface

- (BOOL)setUpWithLaunchOptions:(nullable NSDictionary *)launchOptions
                        apiKey:(NSString *)apiKey
                     urlScheme:(nullable NSString *)urlScheme
                  userDefaults:(nullable NSUserDefaults *)userDefaults {
  if (apiKey == nil) {
    FDLLog(FDLLogLevelError, FDLLogIdentifierSetupNilAPIKey, @"API Key must not be nil.");
    return NO;
  }

  _APIKey = [apiKey copy];
  _URLScheme = urlScheme.length ? [urlScheme copy] : [NSBundle mainBundle].bundleIdentifier;

  if (!userDefaults) {
    _userDefaults = [NSUserDefaults standardUserDefaults];
  } else {
    _userDefaults = userDefaults;
  }

  NSURL *url = launchOptions[UIApplicationLaunchOptionsURLKey];
  if (url) {
    if ([self canParseCustomSchemeURL:url] || [self canParseUniversalLinkURL:url]) {
      // Make sure we don't call |checkForPendingDynamicLink| again if
      // a strong deep link is found.
      [_userDefaults setBool:YES forKey:kFIRDLReadDeepLinkAfterInstallKey];
    }
  }
  return YES;
}

- (void)checkForPendingDynamicLinkUsingExperimentalRetrievalProcess {
  [self checkForPendingDynamicLink];
}

- (void)checkForPendingDynamicLink {
  // Make sure this method is called only once after the application was installed.
  // kFIRDLOpenURLKey marks checkForPendingDynamic link had been called already so no need to do it
  // again. kFIRDLReadDeepLinkAfterInstallKey marks we have already read a deeplink after the
  // install and so no need to do check for pending dynamic link.
  BOOL appInviteDeepLinkRead = [_userDefaults boolForKey:kFIRDLOpenURLKey] ||
                               [_userDefaults boolForKey:kFIRDLReadDeepLinkAfterInstallKey];

  if (appInviteDeepLinkRead || self.retrievingPendingDynamicLink) {
    NSString *errorDescription =
        appInviteDeepLinkRead ? NSLocalizedString(@"Link was already retrieved", @"Error message")
                              : NSLocalizedString(@"Already retrieving link", @"Error message");
    [self handlePendingDynamicLinkRetrievalFailureWithErrorCode:-1
                                               errorDescription:errorDescription
                                                underlyingError:nil];
    return;
  }

  self.retrievingPendingDynamicLink = YES;

  FIRDLRetrievalProcessFactory *factory =
      [[FIRDLRetrievalProcessFactory alloc] initWithNetworkingService:self.dynamicLinkNetworking
                                                            URLScheme:_URLScheme
                                                               APIKey:_APIKey
                                                        FDLSDKVersion:FIRFirebaseVersion()
                                                             delegate:self];
  _retrievalProcess = [factory automaticRetrievalProcess];
  [_retrievalProcess retrievePendingDynamicLink];
}

// Disable deprecated warning for internal methods.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

+ (instancetype)sharedInstance {
  return [self dynamicLinks];
}

- (BOOL)setUpWithLaunchOptions:(nullable NSDictionary *)launchOptions
                        apiKey:(NSString *)apiKey
                      clientID:(NSString *)clientID
                     urlScheme:(nullable NSString *)urlScheme
                  userDefaults:(nullable NSUserDefaults *)userDefaults {
  return [self setUpWithLaunchOptions:launchOptions
                               apiKey:apiKey
                            urlScheme:urlScheme
                         userDefaults:userDefaults];
}

- (void)checkForPendingDeepLink {
  [self checkForPendingDynamicLink];
}

- (nullable FIRDynamicLink *)deepLinkFromCustomSchemeURL:(NSURL *)url {
  return [self dynamicLinkFromCustomSchemeURL:url];
}

- (nullable FIRDynamicLink *)deepLinkFromUniversalLinkURL:(NSURL *)url {
  return [self dynamicLinkFromUniversalLinkURL:url];
}

- (BOOL)shouldHandleDeepLinkFromCustomSchemeURL:(NSURL *)url {
  return [self shouldHandleDynamicLinkFromCustomSchemeURL:url];
}

#pragma clang pop

#pragma mark - Public interface

- (BOOL)shouldHandleDynamicLinkFromCustomSchemeURL:(NSURL *)url {
  // Return NO if the URL scheme does not match.
  if (![self canParseCustomSchemeURL:url]) {
    return NO;
  }

  // We can handle "/link" and "/link/dismiss". The latter will return a nil deep link.
  return ([url.path hasPrefix:@"/link"] && [url.host isEqualToString:@"google"]);
}

- (nullable FIRDynamicLink *)dynamicLinkFromCustomSchemeURL:(NSURL *)url {
  // Return nil if the URL scheme does not match.
  if (![self canParseCustomSchemeURL:url]) {
    return nil;
  }

  if ([url.path isEqualToString:@"/link"] && [url.host isEqualToString:@"google"]) {
    // This URL is a callback url from a fingerprint match
    // Extract information from query.
    NSString *query = url.query;

    NSDictionary *parameters = FIRDLDictionaryFromQuery(query);

    // As long as the deepLink has some parameter, return it.
    if (parameters.count > 0) {
      FIRDynamicLink *dynamicLink =
          [[FIRDynamicLink alloc] initWithParametersDictionary:parameters];

#ifdef GIN_SCION_LOGGING
      if (dynamicLink.url) {
        BOOL isFirstOpen = ![_userDefaults boolForKey:kFIRDLReadDeepLinkAfterInstallKey];
        FIRDLLogEvent event = isFirstOpen ? FIRDLLogEventFirstOpen : FIRDLLogEventAppOpen;
        FIRDLLogEventToScion(event, parameters[kFIRDLParameterSource],
                             parameters[kFIRDLParameterMedium], parameters[kFIRDLParameterCampaign],
                             _analytics);
      }
#endif
      // Make sure we don't call |checkForPendingDynamicLink| again if we did this already.
      if ([_userDefaults boolForKey:kFIRDLOpenURLKey]) {
        [_userDefaults setBool:YES forKey:kFIRDLReadDeepLinkAfterInstallKey];
      }
      return dynamicLink;
    }
  }
  return nil;
}

- (nullable FIRDynamicLink *)
    dynamicLinkInternalFromUniversalLinkURL:(NSURL *)url
                                 completion:
                                     (nullable FIRDynamicLinkUniversalLinkHandler)completion {
  // Make sure the completion is always called on the main queue.
  FIRDynamicLinkUniversalLinkHandler mainQueueCompletion =
      ^(FIRDynamicLink *_Nullable dynamicLink, NSError *_Nullable error) {
        if (completion) {
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(dynamicLink, error);
          });
        }
      };

  if ([self canParseUniversalLinkURL:url]) {
    if (url.query.length > 0) {
      NSDictionary *parameters = FIRDLDictionaryFromQuery(url.query);
      if (parameters[kFIRDLParameterLink]) {
        FIRDynamicLink *dynamicLink = [[FIRDynamicLink alloc] init];
        NSString *urlString = parameters[kFIRDLParameterLink];
        NSURL *deepLinkURL = [NSURL URLWithString:urlString];
        if (deepLinkURL) {
          dynamicLink.url = deepLinkURL;
          dynamicLink.matchType = FIRDLMatchTypeUnique;
          dynamicLink.minimumAppVersion = parameters[kFIRDLParameterMinimumAppVersion];
          // Call resolveShortLink:completion: to do logging.
          // TODO: Create dedicated logging function to prevent this.
          [self.dynamicLinkNetworking
              resolveShortLink:url
                 FDLSDKVersion:FIRFirebaseVersion()
                    completion:^(NSURL *_Nullable resolverURL, NSError *_Nullable resolverError) {
                      mainQueueCompletion(dynamicLink, resolverError);
                    }];
#ifdef GIN_SCION_LOGGING
          FIRDLLogEventToScion(FIRDLLogEventAppOpen, parameters[kFIRDLParameterSource],
                               parameters[kFIRDLParameterMedium],
                               parameters[kFIRDLParameterCampaign], _analytics);
#endif
          return dynamicLink;
        }
      }
    }
  }
  mainQueueCompletion(nil, nil);
  return nil;
}

- (nullable FIRDynamicLink *)dynamicLinkFromUniversalLinkURL:(NSURL *)url {
  return [self dynamicLinkInternalFromUniversalLinkURL:url completion:nil];
}

- (void)dynamicLinkFromUniversalLinkURL:(NSURL *)url
                             completion:(FIRDynamicLinkUniversalLinkHandler)completion {
  [self dynamicLinkInternalFromUniversalLinkURL:url completion:completion];
}

- (BOOL)handleUniversalLink:(NSURL *)universalLinkURL
                 completion:(FIRDynamicLinkUniversalLinkHandler)completion {
  if ([self matchesShortLinkFormat:universalLinkURL]) {
    __weak __typeof__(self) weakSelf = self;
    [self resolveShortLink:universalLinkURL
                completion:^(NSURL *url, NSError *error) {
                  __typeof__(self) strongSelf = weakSelf;
                  if (strongSelf) {
                    FIRDynamicLink *dynamicLink = [strongSelf dynamicLinkFromCustomSchemeURL:url];
                    dispatch_async(dispatch_get_main_queue(), ^{
                      completion(dynamicLink, error);
                    });
                  } else {
                    completion(nil, nil);
                  }
                }];
    return YES;
  } else {
    [self dynamicLinkFromUniversalLinkURL:universalLinkURL completion:completion];
    BOOL canHandleUniversalLink =
        [self canParseUniversalLinkURL:universalLinkURL] && universalLinkURL.query.length > 0 &&
        FIRDLDictionaryFromQuery(universalLinkURL.query)[kFIRDLParameterLink];
    return canHandleUniversalLink;
  }
}

- (void)resolveShortLink:(NSURL *)url completion:(FIRDynamicLinkResolverHandler)completion {
  [self.dynamicLinkNetworking resolveShortLink:url
                                 FDLSDKVersion:FIRFirebaseVersion()
                                    completion:completion];
}

- (BOOL)matchesShortLinkFormat:(NSURL *)url {
  return FIRDLMatchesShortLinkFormat(url);
}

#pragma mark - Private interface

+ (BOOL)isAutomaticRetrievalEnabled {
  id retrievalEnabledValue =
      [[NSBundle mainBundle] infoDictionary][@"FirebaseDeepLinkAutomaticRetrievalEnabled"];
  if ([retrievalEnabledValue respondsToSelector:@selector(boolValue)]) {
    return [retrievalEnabledValue boolValue];
  }
  return YES;
}

#pragma mark - Internal methods

- (FIRDynamicLinkNetworking *)dynamicLinkNetworking {
  if (!_dynamicLinkNetworking) {
    _dynamicLinkNetworking = [[FIRDynamicLinkNetworking alloc] initWithAPIKey:_APIKey
                                                                    URLScheme:_URLScheme];
  }
  return _dynamicLinkNetworking;
}

- (BOOL)canParseCustomSchemeURL:(nullable NSURL *)url {
  if (url.scheme.length) {
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    if ([url.scheme.lowercaseString isEqualToString:_URLScheme.lowercaseString] ||
        [url.scheme.lowercaseString isEqualToString:bundleIdentifier.lowercaseString]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)canParseUniversalLinkURL:(nullable NSURL *)url {
  return FIRDLCanParseUniversalLinkURL(url);
}

- (BOOL)handleIncomingCustomSchemeDeepLink:(NSURL *)url {
  return [self canParseCustomSchemeURL:url];
}

- (void)passRetrievedDynamicLinkToApplication:(NSURL *)url {
  id<UIApplicationDelegate> applicationDelegate = [UIApplication sharedApplication].delegate;
  if ([self isOpenUrlMethodPresentInAppDelegate:applicationDelegate]) {
    // pass url directly to application delegate to avoid hop into
    // iOS handling of the universal links
    [applicationDelegate application:[UIApplication sharedApplication] openURL:url options:@{}];
    return;
  }

  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (BOOL)isOpenUrlMethodPresentInAppDelegate:(id<UIApplicationDelegate>)applicationDelegate {
  return applicationDelegate &&
         [applicationDelegate respondsToSelector:@selector(application:openURL:options:)];
}

- (void)handlePendingDynamicLinkRetrievalFailureWithErrorCode:(NSInteger)errorCode
                                             errorDescription:(NSString *)errorDescription
                                              underlyingError:(nullable NSError *)underlyingError {
  self.retrievingPendingDynamicLink = NO;

  // TODO (b/38035270) inform caller why we failed, for App developer it is hard to debug
  // stuff like this without having source code access
}

#pragma mark - FIRDLRetrievalProcessDelegate

- (void)retrievalProcess:(id<FIRDLRetrievalProcessProtocol>)retrievalProcess
     completedWithResult:(FIRDLRetrievalProcessResult *)result {
  self.retrievingPendingDynamicLink = NO;
  _retrievalProcess = nil;

  if (![_userDefaults boolForKey:kFIRDLOpenURLKey]) {
    // Once we complete the Pending dynamic link retrieval, regardless of whether the retrieval is
    // success or failure, we don't want to do the retrieval again on next app start.
    // If we try to redo the retrieval again because of some error, the user will experience
    // unwanted deeplinking when they restart the app next time.
    [_userDefaults setBool:YES forKey:kFIRDLOpenURLKey];
  }

  NSURL *linkToPassToApp = [result URLWithCustomURLScheme:_URLScheme];
  [self passRetrievedDynamicLinkToApplication:linkToPassToApp];
}

#pragma mark - Diagnostics methods

static NSString *kSelfDiagnoseOutputHeader =
    @"---- Firebase Dynamic Links diagnostic output start ----\n";
// TODO (b/38397557) Add link to the "Debug FDL" documentation when docs is published
static NSString *kSelfDiagnoseOutputFooter =
    @"---- Firebase Dynamic Links diagnostic output end ----\n";

+ (NSString *)genericDiagnosticInformation {
  NSMutableString *genericDiagnosticInfo = [[NSMutableString alloc] init];

  [genericDiagnosticInfo
      appendFormat:@"Firebase Dynamic Links framework version %@\n", FIRFirebaseVersion()];
  [genericDiagnosticInfo appendFormat:@"System information: OS %@, OS version %@, model %@\n",
                                      [UIDevice currentDevice].systemName,
                                      [UIDevice currentDevice].systemVersion,
                                      [UIDevice currentDevice].model];
  [genericDiagnosticInfo appendFormat:@"Current date %@\n", [NSDate date]];
  // TODO: bring this diagnostic info back when we shipped non-automatic retrieval
  //  [genericDiagnosticInfo appendFormat:@"AutomaticRetrievalEnabled: %@\n",
  //                                      [self isAutomaticRetrievalEnabled] ? @"YES" : @"NO"];

  // Disable deprecated warning for internal methods.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [genericDiagnosticInfo appendFormat:@"Device locale %@ (raw %@), timezone %@\n",
                                      FIRDLDeviceLocale(), FIRDLDeviceLocaleRaw(),
                                      FIRDLDeviceTimezone()];
#pragma clang pop

  return genericDiagnosticInfo;
}

+ (NSString *)diagnosticAnalyzeEntitlements {
  NSString *embeddedMobileprovisionFilePath = [[[NSBundle mainBundle] bundlePath]
      stringByAppendingPathComponent:@"embedded.mobileprovision"];

  NSError *error;
  NSMutableData *profileData = [NSMutableData dataWithContentsOfFile:embeddedMobileprovisionFilePath
                                                             options:0
                                                               error:&error];

  if (!profileData.length || error) {
    return @"\tSKIPPED: Not able to read entitlements (embedded.mobileprovision).\n";
  }

  // The "embedded.mobileprovision" sometimes contains characters with value 0, which signals the
  // end of a c-string and halts the ASCII parser, or with value > 127, which violates strict 7-bit
  // ASCII. Replace any 0s or invalid characters in the input.
  uint8_t *profileBytes = (uint8_t *)profileData.bytes;
  for (int i = 0; i < profileData.length; i++) {
    uint8_t currentByte = profileBytes[i];
    if (!currentByte || currentByte > 127) {
      profileBytes[i] = '.';
    }
  }

  NSString *embeddedProfile = [[NSString alloc] initWithBytesNoCopy:profileBytes
                                                             length:profileData.length
                                                           encoding:NSASCIIStringEncoding
                                                       freeWhenDone:NO];

  if (error || !embeddedProfile.length) {
    return @"\tSKIPPED: Not able to read entitlements (embedded.mobileprovision).\n";
  }

  NSScanner *scanner = [NSScanner scannerWithString:embeddedProfile];
  NSString *plistContents;
  if ([scanner scanUpToString:@"<plist" intoString:nil]) {
    if ([scanner scanUpToString:@"</plist>" intoString:&plistContents]) {
      plistContents = [plistContents stringByAppendingString:@"</plist>"];
    }
  }

  if (!plistContents.length) {
    return @"\tWARNING: Not able to read plist entitlements (embedded.mobileprovision).\n";
  }

  NSData *data = [plistContents dataUsingEncoding:NSUTF8StringEncoding];
  if (!data.length) {
    return @"\tWARNING: Not able to parse entitlements (embedded.mobileprovision).\n";
  }

  NSError *plistMapError;
  id plistData = [NSPropertyListSerialization propertyListWithData:data
                                                           options:NSPropertyListImmutable
                                                            format:nil
                                                             error:&plistMapError];
  if (plistMapError || ![plistData isKindOfClass:[NSDictionary class]]) {
    return @"\tWARNING: Not able to deserialize entitlements (embedded.mobileprovision).\n";
  }
  NSDictionary *plistMap = (NSDictionary *)plistData;

  // analyze entitlements and print diagnostic information
  // we can't detect erorrs, information p[rinted here may hint developer or will help support
  // to identify the issue
  NSMutableString *outputString = [[NSMutableString alloc] init];

  NSArray *appIdentifierPrefixes = plistMap[@"ApplicationIdentifierPrefix"];
  NSString *teamID = plistMap[@"Entitlements"][@"com.apple.developer.team-identifier"];

  if (appIdentifierPrefixes.count > 1) {
    // is this possible? anyway, we can handle it
    [outputString
        appendFormat:@"\tAppID Prefixes: %@, Team ID: %@, AppId Prefixes contains to Team ID: %@\n",
                     appIdentifierPrefixes, teamID,
                     ([appIdentifierPrefixes containsObject:teamID] ? @"YES" : @"NO")];
  } else {
    [outputString
        appendFormat:@"\tAppID Prefix: %@, Team ID: %@, AppId Prefix equal to Team ID: %@\n",
                     appIdentifierPrefixes[0], teamID,
                     ([appIdentifierPrefixes[0] isEqualToString:teamID] ? @"YES" : @"NO")];
  }

  return outputString;
}

+ (NSString *)performDiagnosticsIncludingHeaderFooter:(BOOL)includingHeaderFooter
                                       detectedErrors:(nullable NSInteger *)detectedErrors {
  NSMutableString *diagnosticString = [[NSMutableString alloc] init];
  if (includingHeaderFooter) {
    [diagnosticString appendString:@"\n"];
    [diagnosticString appendString:kSelfDiagnoseOutputHeader];
  }

  NSInteger detectedErrorsCnt = 0;

  [diagnosticString appendString:[self genericDiagnosticInformation]];

#if TARGET_IPHONE_SIMULATOR
  // check is Simulator and print WARNING that Universal Links is not supported on Simulator
  [diagnosticString
      appendString:@"WARNING: iOS Simulator does not support Universal Links. Firebase "
                   @"Dynamic Links SDK functionality will be limited. Some FDL "
                   @"features may be missing or will not work correctly.\n"];
#endif  // TARGET_IPHONE_SIMULATOR

  id<UIApplicationDelegate> applicationDelegate = [UIApplication sharedApplication].delegate;
  if (![applicationDelegate respondsToSelector:@selector(application:openURL:options:)]) {
    detectedErrorsCnt++;
    [diagnosticString appendFormat:@"ERROR: UIApplication delegate %@ does not implements selector "
                                   @"%@. FDL depends on this implementation to retrieve pending "
                                   @"dynamic link.\n",
                                   applicationDelegate,
                                   NSStringFromSelector(@selector(application:openURL:options:))];
  }

  // check that Info.plist has custom URL scheme and the scheme is the same as bundleID or
  // as customURLScheme passed to FDL iOS SDK
  NSString *URLScheme = [FIRDynamicLinks dynamicLinks].URLScheme;
  BOOL URLSchemeFoundInPlist = NO;
  NSArray *URLSchemesFromInfoPlist = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
  for (NSDictionary *schemeDetails in URLSchemesFromInfoPlist) {
    NSArray *arrayOfSchemes = schemeDetails[@"CFBundleURLSchemes"];
    for (NSString *scheme in arrayOfSchemes) {
      if ([scheme isEqualToString:URLScheme]) {
        URLSchemeFoundInPlist = YES;
        break;
      }
    }
    if (URLSchemeFoundInPlist) {
      break;
    }
  }
  if (!URLSchemeFoundInPlist) {
    detectedErrorsCnt++;
    [diagnosticString appendFormat:@"ERROR: Specified custom URL scheme is %@ but Info.plist do "
                                   @"not contain such scheme in "
                                    "CFBundleURLTypes key.\n",
                                   URLScheme];
  } else {
    [diagnosticString appendFormat:@"\tSpecified custom URL scheme is %@ and Info.plist contains "
                                   @"such scheme in CFBundleURLTypes key.\n",
                                   URLScheme];
  }

#if !TARGET_IPHONE_SIMULATOR
  // analyse information in entitlements file
  NSString *entitlementsAnalysis = [self diagnosticAnalyzeEntitlements];
  if (entitlementsAnalysis.length) {
    [diagnosticString appendString:entitlementsAnalysis];
  }
#endif  // TARGET_IPHONE_SIMULATOR

  if (includingHeaderFooter) {
    if (detectedErrorsCnt == 0) {
      [diagnosticString
          appendString:@"performDiagnostic completed successfully! No errors found.\n"];
    } else {
      [diagnosticString
          appendFormat:@"performDiagnostic detected %ld ERRORS.\n", (long)detectedErrorsCnt];
    }
    [diagnosticString appendString:kSelfDiagnoseOutputFooter];
  }
  if (detectedErrors) {
    *detectedErrors = detectedErrorsCnt;
  }
  return [diagnosticString copy];
}

+ (void)performDiagnosticsWithCompletion:(void (^_Nullable)(NSString *diagnosticOutput,
                                                            BOOL hasErrors))completionHandler;
{
  NSInteger detectedErrorsCnt = 0;
  NSString *diagnosticString = [self performDiagnosticsIncludingHeaderFooter:YES
                                                              detectedErrors:&detectedErrorsCnt];
  if (completionHandler) {
    completionHandler(diagnosticString, detectedErrorsCnt > 0);
  } else {
    NSLog(@"%@", diagnosticString);
  }
}

@end

NS_ASSUME_NONNULL_END

#endif  // TARGET_OS_IOS
