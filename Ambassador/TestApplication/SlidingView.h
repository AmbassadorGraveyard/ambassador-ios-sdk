//
//  SlidingView.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/18/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlidingView;

@protocol SlidingViewDatasource <NSObject>

- (NSInteger)slidingViewCollapsedHeight:(SlidingView *)slidingView;
- (NSInteger)slidingViewExpandedHeight:(SlidingView *)slidingView;

@end


@interface SlidingView : UIView

@property (nonatomic, weak) id<SlidingViewDatasource> datasource;

@end

