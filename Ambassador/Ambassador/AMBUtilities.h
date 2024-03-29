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
#import "AMBSendCompletionModal.h"

// Protocal
@protocol AMBUtilitiesDelegate <NSObject>

@optional
- (void)okayButtonClickedForUniqueID:(NSString*)uniqueID;

@end


@interface AMBUtilities : NSObject <AMBSendCompletionDelegate>

@property (nonatomic, weak)id <AMBUtilitiesDelegate> delegate;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView * fadeView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView * animatingView;
@property (nonatomic, strong) NSCache * cache;

+ (AMBUtilities *)sharedInstance;

// Custom Alerts
- (void)presentAlertWithSuccess:(BOOL)successful message:(NSString*)message withUniqueID:(NSString*)uniqueID forViewController:(UIViewController*)viewController shouldDismissVCImmediately:(BOOL)shouldDismiss;

// Loading Screen
- (void)showLoadingScreenForView:(UIView*)view;
- (void)hideLoadingView;
- (void)rotateLoadingView:(UIView*)view orientation:(UIInterfaceOrientation)orientation;

// Fade View
- (void)addFadeToView:(UIView*)view;
- (void)removeFadeFromView;
- (void)rotateFadeForView:(UIView*)view;

// Misc Class Functions
+ (NSString*)createRequestID;
+ (NSString*)create32CharCode;
+ (BOOL)colorIsDark:(UIColor*)color;
+ (BOOL)isSuccessfulStatusCode:(NSInteger)statusCode;
+ (NSDictionary*)dictionaryFromQueryString:(NSString*)queryString;
+ (BOOL)stringIsEmpty:(NSString*)string;
+ (UIViewController*)getTopViewController;

@end


