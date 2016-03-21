//
//  RAFCell.h
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RAFCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel * rafName;
@property (nonatomic, strong) IBOutlet UIButton * btnExport;

- (void)setUpCellWithRafName:(NSString*)rafName;

@end
