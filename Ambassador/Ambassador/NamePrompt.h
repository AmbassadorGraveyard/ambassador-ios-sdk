//
//  NamePrompt.h
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NamePromptDelegate <NSObject>

- (void)sendSMSPressedWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end

@interface NamePrompt : UIViewController

@property (weak)id<NamePromptDelegate>delegate;

@end
