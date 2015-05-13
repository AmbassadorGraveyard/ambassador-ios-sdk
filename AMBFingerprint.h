//
//  AMBFingerprint.h
//  ObjC
//
//  Created by Diplomat on 5/13/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMBBase.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AMBFingerprint : NSObject

- (void)registerFingerprint;

@property NSDictionary* jsonResponse;

@end