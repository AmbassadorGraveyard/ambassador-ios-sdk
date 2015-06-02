//
//  Ambassador.h
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Ambassador : NSObject

//+ (Ambassador*)sharedInstance;
- (void)setAPIKey:(NSString *)key;
- (void)registerConversion;
+ (Ambassador *)sharedInstance;
- (void)presentRAFFromViewController:(UIViewController *)viewController;
- (NSMutableDictionary *)getPreferencesData;
@end
