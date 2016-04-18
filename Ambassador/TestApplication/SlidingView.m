//
//  SlidingView.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SlidingView.h"

@interface SlidingView()

@property (nonatomic) NSInteger collapsedHeight;
@property (nonatomic) NSInteger expandedHeight;
@property (nonatomic) BOOL isExpanded;

@end


@implementation SlidingView

#pragma mark - LifeCycle

- (void)awakeFromNib {
    if (self.datasource) {
        self.collapsedHeight = [self.datasource slidingViewCollapsedHeight:self];
        self.expandedHeight = [self.datasource slidingViewExpandedHeight:self];
    }
}


#pragma mark - Expand/Collapse

- (void)expand {
    
}

- (void)collapse {
    
}

@end
