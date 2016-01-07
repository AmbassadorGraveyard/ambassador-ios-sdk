//
//  Utilities.h
//  iOS_Framework
//
//  Created by Diplomat on 7/15/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#ifndef iOS_Framework_Utilities_h
#define iOS_Framework_Utilities_h

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Protocal
@protocol AMBUtilitiesDelegate <NSObject>

@optional
- (void)okayButtonClickedForUniqueID:(NSString*)uniqueID;

@end


@interface AMBUtilities : NSObject

@property (nonatomic, weak)id <AMBUtilitiesDelegate> delegate;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView * animatingView;
@property (nonatomic, strong) NSCache * cache;

+ (AMBUtilities *)sharedInstance;

- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message withUniqueID:(NSString*)uniqueID forViewController:(UIViewController*)viewController shouldDismissVCImmediately:(BOOL)shouldDismiss;
- (void)showLoadingScreenForView:(UIView*)view;
- (void)hideLoadingView;
- (void)saveToCache:(NSObject*)value forKey:(NSString*)keyValue;
- (NSObject*)getCacheValueWithKey:(NSString*)key;
- (void)removeCacheForKey:(NSString*)keyValue;

+ (NSString*)createRequestID;
+ (BOOL)isSuccessfulStatusCode:(NSInteger)statusCode;

@end


NSMutableDictionary* AMBparseQueryString(NSString *string);
UIColor* AMBColorFromRGB(float r, float g, float b);
void AMBsimpleAlert(NSString *title, NSString *message, UIViewController *vc);
NSString* AMBStringValFromDictionary(NSMutableDictionary *d, NSString *key);
NSArray *AMBArrayFromDicstionary(NSMutableDictionary *d, NSString *key);
NSString* AMBOptionalString(NSString *s);

#endif
