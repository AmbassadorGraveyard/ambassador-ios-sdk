//
//  ContactsTableVC.h
//  iOS_Framework
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedTableVC.h"

@interface ContactsTableVC : UIViewController
@property NSMutableArray *data;
@property UITableView *tableView;
@property NSMutableSet *selected;
@property (weak) id<SelectedContactsProtocol>delegate;
@end
