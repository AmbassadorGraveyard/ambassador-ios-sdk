//
//  Identify.h
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface AMBIdentify : NSObject

@property (nonatomic) BOOL identifyProcessComplete;
@property (nonatomic, strong) SFSafariViewController * safariVC;

- (id)init;
- (void)getIdentity:(void (^)(BOOL))completion;
   
@end
