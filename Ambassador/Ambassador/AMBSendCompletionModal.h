//
//  SendCompletionModal.h
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBSendCompletionModal : UIViewController

@property NSString *alertMessage;
@property BOOL successFlag;
@property (nonatomic, copy)void (^buttonAction)();

@end
