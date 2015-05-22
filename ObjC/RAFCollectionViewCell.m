//
//  RAFCollectionViewCell.m
//  AnalyticsApp
//
//  Created by Diplomat on 5/22/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "RAFCollectionViewCell.h"

@implementation RAFCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
//        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.size.height -15, frame.size.width, 15)];
//        self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.textColor = [UIColor blackColor];
//        self.label.font = [UIFont boldSystemFontOfSize:15.0];
//        self.label.backgroundColor = [UIColor whiteColor];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width / 2 ) - 12, 0, 36, 36)];
        //self.image.frame = CGRectMake((frame.size.width / 2 ) - 32, 0, 64, 64);
        [self.contentView addSubview:self.image];
        //[self.contentView addSubview:self.label];
    }
    return self;
}

@end
