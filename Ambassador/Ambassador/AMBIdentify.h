//
//  Identify.h
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AMBIdentify : NSObject

@property (nonatomic) BOOL identifyProcessComplete;

- (id)init;
- (void)getIdentity;

@end