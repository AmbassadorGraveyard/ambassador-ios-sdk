//
//  GroupListViewController.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupListDelegate <NSObject>

- (void)groupListSelectedGroups:(NSArray *)groups;

@end


@interface GroupListViewController : UIViewController

@property (nonatomic, weak) id<GroupListDelegate> delegate;

@end
