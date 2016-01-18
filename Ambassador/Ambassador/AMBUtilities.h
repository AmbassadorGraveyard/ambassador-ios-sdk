//
//  Utilities.h
//  iOS_Framework
//
//  Created by Diplomat on 7/15/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

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

// Custom Alerts
- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message withUniqueID:(NSString*)uniqueID forViewController:(UIViewController*)viewController shouldDismissVCImmediately:(BOOL)shouldDismiss;

// Loading Screen
- (void)showLoadingScreenForView:(UIView*)view;
- (void)hideLoadingView;
- (void)rotateLoadingView:(UIView*)view widthOffset:(CGFloat)widthOffset;
+ (CGFloat)getOffsetForRotation:(UIViewController*) viewController toOrientation:(UIInterfaceOrientation)toOrientation;

// Caching
- (void)saveToCache:(NSObject*)value forKey:(NSString*)keyValue;
- (NSObject*)getCacheValueWithKey:(NSString*)key;
- (void)removeCacheForKey:(NSString*)keyValue;

// Misc Class Functions
+ (NSString*)createRequestID;
+ (BOOL)isSuccessfulStatusCode:(NSInteger)statusCode;
+ (NSDictionary*)dictionaryFromQueryString:(NSString*)queryString;

@end


