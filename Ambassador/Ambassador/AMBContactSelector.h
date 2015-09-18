//
//  ContactSelector.h
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBServiceSelectorPreferences.h"

@protocol AMBContactSelectorDelegate <NSObject>

- (void)sendToContacts:(NSArray*)values forServiceType:(NSString *)serviceType fromFirstName:(NSString *)firstName lastName:(NSString *)lastName withMessage:(NSString *)string;

@end

@interface AMBContactSelector : UIViewController

@property NSMutableArray *data;
@property AMBServiceSelectorPreferences *prefs;
@property NSString *defaultMessage;
@property NSString *shortCode;
@property NSString *shortURL;
@property (weak)id<AMBContactSelectorDelegate>delegate;
@property NSString *serviceType;

@end
