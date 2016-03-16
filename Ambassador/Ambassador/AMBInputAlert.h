//
//  AMBCustomInputController.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/16/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMBInputAlertDelegate <NSObject>

- (void)actionButtonTapped;

@end


@interface AMBInputAlert : UIViewController

// Public properties
@property (nonatomic, weak) id<AMBInputAlertDelegate> delegate;

// Public functions
- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message placeHolder:(NSString*)placeHolder actionButton:(NSString*)actionButton;

@end
