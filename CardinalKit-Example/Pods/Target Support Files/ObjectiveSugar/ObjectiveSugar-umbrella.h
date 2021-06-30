#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+ObjectiveSugar.h"
#import "NSDictionary+ObjectiveSugar.h"
#import "NSMutableArray+ObjectiveSugar.h"
#import "NSNumber+ObjectiveSugar.h"
#import "NSSet+ObjectiveSugar.h"
#import "NSString+ObjectiveSugar.h"
#import "ObjectiveSugar.h"

FOUNDATION_EXPORT double ObjectiveSugarVersionNumber;
FOUNDATION_EXPORT const unsigned char ObjectiveSugarVersionString[];

