//
//  ContactSelector.h
//  RAF
//
//  Created by Diplomat on 7/24/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceSelectorPreferences.h"

@protocol ContactSelectorDelegate <NSObject>

- (void)sendValues:(NSArray*)values forServiceType:(NSString *)serviceType;

@end

@interface ContactSelector : UIViewController

@property NSMutableArray *data;
@property ServiceSelectorPreferences *prefs;
@property NSString *shortCode;
@property (weak)id<ContactSelectorDelegate>delegate;
@property NSString *serviceType;

@end
