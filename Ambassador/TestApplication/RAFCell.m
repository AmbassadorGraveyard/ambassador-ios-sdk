//
//  RAFCell.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/12/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFCell.h"

@interface RAFCell()

// IBOutlets
@property (nonatomic, strong) IBOutlet UILabel * rafName;
@property (nonatomic, strong) IBOutlet UILabel * lblDateCreated;
@property (nonatomic, strong) IBOutlet UIButton * btnExport;
@property (nonatomic, strong) IBOutlet UIButton * btnDelete;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * removeButtonLeading;

// Private properties
@property (nonatomic, strong) RAFItem * currentItem;

@end


@implementation RAFCell


#pragma mark - Setup

- (void)setUpCellWithRaf:(RAFItem*)rafItem {
    // TableView Cell
    self.preservesSuperviewLayoutMargins = NO;
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    self.currentItem = rafItem;
    
    // Labels
    self.rafName.text = rafItem.rafName;
    self.lblDateCreated.text = [self stringFromDate:rafItem.dateCreated];
    
    // Button
    [self.btnExport setImage:[[UIImage imageNamed:@"exportIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.btnExport setImage:[[UIImage imageNamed:@"rightArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateDisabled];
    self.btnExport.tintColor = [UIColor lightGrayColor];
    self.btnExport.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Constraints
    [self showHideDeleteButton];
}


#pragma mark - Button Actions

- (IBAction)deleteTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RAFCellDeleteTappedForRAFItem:)]) {
        [self.delegate RAFCellDeleteTappedForRAFItem:self.currentItem];
    }
}

- (IBAction)exportTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(RAFCellExportTappedForRAFItem:)]) {
        [self.delegate RAFCellExportTappedForRAFItem:self.currentItem];
    }
}


#pragma mark - Helper Functions

- (NSString*)stringFromDate:(NSDate*)date {
    // Gets date 'month/day/year'
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = @"MM/dd/yyyy";
    NSString *dateString = [dayFormatter stringFromDate:date];
    
    // Gets time '12:00:00 AM'
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss a";
    NSString *timeString = [timeFormatter stringFromDate:date];
    
    return [NSString stringWithFormat:@"created on %@ at %@", dateString, timeString];
}

- (void)showHideDeleteButton {
    self.removeButtonLeading.constant = (self.isEditing) ? 20 : -(self.btnDelete.frame.size.width);
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.3 animations:^{
            [self layoutIfNeeded];
            self.btnExport.enabled = !self.isEditing;
        }];
    } completion:nil];
}

@end
