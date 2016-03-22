//
//  RAFCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCell.h"

@interface RAFCell()

@property (nonatomic, strong) IBOutlet UILabel * rafName;
@property (nonatomic, strong) IBOutlet UILabel * lblDateCreated;
@property (nonatomic, strong) IBOutlet UIButton * btnExport;

@end

@implementation RAFCell

- (void)setUpCellWithRaf:(RAFItem*)rafItem {
    // TableView Cell
    self.preservesSuperviewLayoutMargins = NO;
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    
    // Labels
    self.rafName.text = rafItem.rafName;
    self.lblDateCreated.text = [self stringFromDate:rafItem.dateCreated];
    
    // Button
    [self.btnExport setImage:[self.btnExport.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.btnExport.tintColor = [UIColor lightGrayColor];
}

- (NSString*)stringFromDate:(NSDate*)date {
    // Gets date 'month/day/year'
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dayFormatter stringFromDate:date];
    
    // Gets time 12:00:00 AM
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss a";
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    return [NSString stringWithFormat:@"created on %@ at %@", dateString, timeString];
}

@end
