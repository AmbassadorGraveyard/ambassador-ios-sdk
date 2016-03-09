//
//  AmbassadorLoginViewController.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/3/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AmbassadorLoginDelegate <NSObject>

- (void)userSuccessfullyLoggedIn;

@end


@interface AmbassadorLoginViewController : UIViewController

@property (nonatomic, weak) id<AmbassadorLoginDelegate> delegate;

@end
