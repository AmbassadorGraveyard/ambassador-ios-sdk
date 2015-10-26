//
//  ContactSelector.h
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBServiceSelectorPreferences.h"
#import "AMBOptions.h"
#import "AMBNetworkObject.h"

@protocol AMBContactSelectorDelegate <NSObject>

- (void)sendToContacts:(NSArray*)values forServiceType:(NSString *)serviceType fromFirstName:(NSString *)firstName lastName:(NSString *)lastName withMessage:(NSString *)string;

@end

@interface AMBContactSelector : UIViewController

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) AMBServiceSelectorPreferences *prefs;
@property (nonatomic, strong) NSString *defaultMessage;
@property (nonatomic, strong) NSString *shortCode;
@property (nonatomic, strong) NSString *shortURL;
@property (nonatomic, weak)id<AMBContactSelectorDelegate>delegate;
@property (nonatomic) AMBSocialServiceType type;
@property (nonatomic, strong) AMBUserUrlNetworkObject *urlNetworkObject;

@end
