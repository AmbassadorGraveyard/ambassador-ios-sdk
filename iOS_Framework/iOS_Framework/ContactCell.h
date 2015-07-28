//
//  ContactCell.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *value;

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkView;

@end
