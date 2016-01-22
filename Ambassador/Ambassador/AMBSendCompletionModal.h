//
//  SendCompletionModal.h
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMBSendCompletionDelegate <NSObject>

- (void)buttonClicked;

@end


@interface AMBSendCompletionModal : UIViewController

@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic) BOOL successFlag;
@property (nonatomic, weak) id<AMBSendCompletionDelegate> delegate;

@end
