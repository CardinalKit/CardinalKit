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

#import <WebKit/WebKit.h>

#import "FirebaseDynamicLinks/Sources/FIRDLJavaScriptExecutor.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kJSMethodName = @"generateFingerprint";

/** Creates and returns the FDL JS method name. */
NSString *FIRDLTypeofFingerprintJSMethodNameString() {
  static NSString *methodName;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    methodName = [NSString stringWithFormat:@"typeof(%@)", kJSMethodName];
  });
  return methodName;
}

/** Creates and returns the FDL JS method definition. */
NSString *GINFingerprintJSMethodString() {
  static NSString *methodString;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    methodString = [NSString stringWithFormat:@"%@()", kJSMethodName];
  });
  return methodString;
}

@interface FIRDLJavaScriptExecutor () <WKNavigationDelegate>
@end

@implementation FIRDLJavaScriptExecutor {
  __weak id<FIRDLJavaScriptExecutorDelegate> _delegate;
  NSString *_script;

  // Web view with which to run JavaScript.
  WKWebView *_wkWebView;
}

- (instancetype)initWithDelegate:(id<FIRDLJavaScriptExecutorDelegate>)delegate
                          script:(NSString *)script {
  NSParameterAssert(delegate);
  NSParameterAssert(script);
  NSParameterAssert(script.length > 0);
  NSAssert([NSThread isMainThread], @"%@ must be used in main thread",
           NSStringFromClass([self class]));
  if (self = [super init]) {
    _delegate = delegate;
    _script = [script copy];
    [self start];
  }
  return self;
}

#pragma mark - Internal methods
- (void)start {
  NSString *htmlContent =
      [NSString stringWithFormat:@"<html><head><script>%@</script></head></html>", _script];

  _wkWebView = [[WKWebView alloc] init];
  _wkWebView.navigationDelegate = self;
  [_wkWebView loadHTMLString:htmlContent baseURL:nil];
}

- (void)handleExecutionResult:(NSString *)result {
  [self cleanup];
  [_delegate javaScriptExecutor:self completedExecutionWithResult:result];
}

- (void)handleExecutionError:(nullable NSError *)error {
  [self cleanup];
  if (!error) {
    error = [NSError errorWithDomain:@"com.firebase.durabledeeplink" code:-1 userInfo:nil];
  }
  [_delegate javaScriptExecutor:self failedWithError:error];
}

- (void)cleanup {
  _wkWebView.navigationDelegate = nil;
  _wkWebView = nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    didFinishNavigation:(null_unspecified WKNavigation *)navigation {
  __weak __typeof__(self) weakSelf = self;

  // Make sure that the javascript was loaded successfully before calling the method.
  [webView evaluateJavaScript:FIRDLTypeofFingerprintJSMethodNameString()
            completionHandler:^(id _Nullable typeofResult, NSError *_Nullable typeError) {
              if (typeError) {
                [weakSelf handleExecutionError:typeError];
                return;
              }
              if ([typeofResult isEqual:@"function"]) {
                [webView
                    evaluateJavaScript:GINFingerprintJSMethodString()
                     completionHandler:^(id _Nullable result, NSError *_Nullable functionError) {
                       __typeof__(self) strongSelf = weakSelf;
                       if ([result isKindOfClass:[NSString class]]) {
                         [strongSelf handleExecutionResult:result];
                       } else {
                         [strongSelf handleExecutionError:nil];
                       }
                     }];
              } else {
                [weakSelf handleExecutionError:nil];
              }
            }];
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(NSError *)error {
  [self handleExecutionError:error];
}

@end

NS_ASSUME_NONNULL_END

#endif  // TARGET_OS_IOS
