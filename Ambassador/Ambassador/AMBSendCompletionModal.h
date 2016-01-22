//
//  SendCompletionModal.h
//  modal
//
//  Created by Diplomat on 8/12/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMBSendCompletionDelegate <NSObject>

- (void)buttonClickedWithPresentingVC:(UIViewController*)viewController shouldDismissPresentingVC:(BOOL)dismissPresenter uniqueID:(NSString*)uniqueID;

@end


@interface AMBSendCompletionModal : UIViewController

@property (nonatomic, strong) NSString * alertMessage;
@property (nonatomic, strong) UIViewController * presentingVC;
@property (nonatomic, strong) NSString * uniqueIdentifier;
@property (nonatomic) BOOL showSuccess;
@property (nonatomic) BOOL shouldDismissPresentingVC;
@property (nonatomic, weak) id<AMBSendCompletionDelegate> delegate;

@end
