//
//  SlidingView.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlidingView;

// Datasource
@protocol SlidingViewDatasource <NSObject>

- (NSInteger)slidingViewCollapsedHeight:(SlidingView *)slidingView;
- (NSInteger)slidingViewExpandedHeight:(SlidingView *)slidingView;

@end

// Delegate
@protocol SlidingViewDelegate <NSObject>

@optional
- (void)slidingViewExpanded:(SlidingView *)slidingView;
- (void)slidingViewCollapsed:(SlidingView *)slidingView;

@end

// Class
@interface SlidingView : UIView

@property (nonatomic, weak) id<SlidingViewDatasource> datasource;
@property (nonatomic, weak) id<SlidingViewDelegate> delegate;

- (void)setup;
- (void)setNewExpandedHeight:(NSInteger)newHeight;

@end

