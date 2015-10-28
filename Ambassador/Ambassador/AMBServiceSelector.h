//
//  ServiceSelector.h
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBServiceSelectorPreferences.h"

@interface AMBServiceSelector : UIViewController

- (void)removeWaitView;

@property (strong, nonatomic) AMBServiceSelectorPreferences *prefs;
@property NSString *APIKey;
@property NSString *campaignID;

@end
