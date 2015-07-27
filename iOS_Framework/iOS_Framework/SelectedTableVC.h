//
//  SelectedTableVC.h
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedContactsProtocol <NSObject>
- (void)selectedContactsChanged;
@end

@interface SelectedTableVC : UIViewController
@property NSMutableArray *data;
@property UITableView *tableView;
@property NSMutableSet *selected;
@property (weak) id<SelectedContactsProtocol>delegate;
@end
