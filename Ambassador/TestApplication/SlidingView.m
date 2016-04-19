//
//  SlidingView.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SlidingView.h"

@interface SlidingView()

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView * targetView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * viewHeight;

// Private properties
@property (nonatomic) NSInteger collapsedHeight;
@property (nonatomic) NSInteger expandedHeight;
@property (nonatomic) BOOL isExpanded;

@end


@implementation SlidingView

#pragma mark - LifeCycle

- (void)setup {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slide)];
    [self.targetView addGestureRecognizer:tapGesture];
    
    self.isExpanded = YES;
    
    if (self.datasource) {
        self.collapsedHeight = [self.datasource slidingViewCollapsedHeight:self];
        self.expandedHeight = [self.datasource slidingViewExpandedHeight:self];
    }
}


#pragma mark - Expand/Collapse

- (void)slide {
    if (self.isExpanded) {
        [self collapse];
    } else {
        [self expand];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.superview layoutIfNeeded];
    }];
}

- (void)expand {
    self.viewHeight.constant = self.expandedHeight;
    self.isExpanded = YES;
}

- (void)collapse {
    self.viewHeight.constant = self.collapsedHeight;
    self.isExpanded = NO;
}

@end
