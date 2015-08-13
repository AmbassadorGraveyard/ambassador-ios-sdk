//
//  SendCompletionModal.h
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCompletionModal : UIViewController

@property NSString *alertMessage;
- (void)shouldUseSuccessIcon:(BOOL)successful;
@property (nonatomic, copy)void (^buttonAction)();

@end
