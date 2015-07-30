//
//  NamePrompt.h
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NamePromptDelegate <NSObject>

- (void)sendSMSPressed;

@end

@interface NamePrompt : UIViewController

@property (weak)id<NamePromptDelegate>delegate;

@end
