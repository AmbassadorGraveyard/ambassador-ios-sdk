//
//  SocialCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialCellDelegate <NSObject>

- (void)socialChannel:(NSString*)channel enableStatusUpdated:(BOOL)enabled orderIndex:(NSInteger)index;

@end


@interface SocialCell : UITableViewCell

// Public properties
@property (nonatomic, weak) id<SocialCellDelegate> delegate;

// Public functions
- (void)setUpCellWithName:(NSString*)name isEnabled:(BOOL)enabled orderIndex:(NSInteger)index;

@end
