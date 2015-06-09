//
//  Identify.h
//  Ambassador
//
//  Created by Diplomat on 5/29/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Identify : NSObject

- (BOOL)identify;
- (id)init;

@property NSMutableDictionary *identifyData;

@end
