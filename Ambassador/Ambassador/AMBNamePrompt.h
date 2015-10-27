//
//  NamePrompt.h
//  iOS_Framework
//
//  Created by Diplomat on 7/29/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMBNamePromptDelegate <NSObject>

- (void)sendSMSPressedWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)namesUpdatedSuccessfully;

@end

@interface AMBNamePrompt : UIViewController

@property (weak)id<AMBNamePromptDelegate>delegate;

@end
