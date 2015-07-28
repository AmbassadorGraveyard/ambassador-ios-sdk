//
//  ContactSelector.h
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceSelectorPreferences.h"

@interface ContactSelector : UIViewController

@property NSMutableArray *data;
@property ServiceSelectorPreferences *prefs;
@property NSString *shortCode;

@end
