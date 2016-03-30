//
//  SocialShareOptionsHandler.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SocialShareHandlerDelegate <NSObject>

// Delegate functions
- (void)socialShareHandlerUpdated:(NSMutableArray*)socialArray;
- (void)socialShareHandlerEnabledObjectsUpdated:(NSMutableArray*)enabledArray;

@end


@interface SocialShareOptionsHandler : NSObject <UITableViewDataSource, UITableViewDelegate>

// Public properties
@property (nonatomic, weak) id<SocialShareHandlerDelegate> delegate;

// Custom Initializer
- (id)initWithArrayOrder:(NSMutableArray*)fullArray onArray:(NSMutableArray*)onArray;

@end
