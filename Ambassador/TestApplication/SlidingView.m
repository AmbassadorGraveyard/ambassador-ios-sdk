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
@property (nonatomic, strong) IBOutlet UIImageView * ivIndicator;

// Private properties
@property (nonatomic) NSInteger collapsedHeight;
@property (nonatomic) NSInteger expandedHeight;
@property (nonatomic) BOOL isExpanded;

@end


@implementation SlidingView

#pragma mark - LifeCycle

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    // Sets up the TARGET VIEW -- which triggers the slide
    if (![self.targetView isKindOfClass:[UISwitch class]]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slide)];
        [self.targetView addGestureRecognizer:tapGesture];
        self.isExpanded = YES;
    } else {
        // If the target view is a UISwitch, we switch the trigger from a tap to turning it on and off
        UISwitch *showSwitch = (UISwitch*)self.targetView;
        [showSwitch addTarget:self action:@selector(slide) forControlEvents:UIControlEventValueChanged];
        self.isExpanded = NO;
    }
    
    // Turns rotate indicator according to state(the arrow)
    [self rotateIndicator];
    self.ivIndicator.image = [self.ivIndicator.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    // Sets value based on datasource
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
}

- (void)expand {
    self.viewHeight.constant = self.expandedHeight;
    self.isExpanded = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.superview layoutIfNeeded];
        [self rotateIndicator];
    }];
    
    // Tells delegate that the view expanded
    if ([self.delegate respondsToSelector:@selector(slidingViewExpanded:)]) { [self.delegate slidingViewExpanded:self]; }
}

- (void)collapse {
    self.viewHeight.constant = self.collapsedHeight;
    self.isExpanded = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.superview layoutIfNeeded];
        [self rotateIndicator];
    }];
    
    // Tells delegate that the view collapsed
    if ([self.delegate respondsToSelector:@selector(slidingViewCollapsed:)]) { [self.delegate slidingViewCollapsed:self]; }
}

- (void)rotateIndicator {
    CGFloat rotateDegrees = self.isExpanded ? M_PI_2 : 0;
    self.ivIndicator.transform = CGAffineTransformMakeRotation(rotateDegrees);
}

// Handes a slidingView within a slidingView
- (void)setNewExpandedHeight:(NSInteger)newHeight {
    self.expandedHeight = newHeight;
    [self expand];
}

@end
