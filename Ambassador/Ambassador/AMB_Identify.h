//
//  AMBASSADORConversion.h
//  Ambassador
//
//  Created by Diplomat on 5/27/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface AMB_Identify : NSObject

- (BOOL)identify;
- (id)init;

@property NSDictionary *conversionJSONResponse;

@end
