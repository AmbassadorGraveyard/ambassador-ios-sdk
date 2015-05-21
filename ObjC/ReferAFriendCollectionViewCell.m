//
//  ReferAFriendCollectionViewCell.m
//  ObjC
//
//  Created by Diplomat on 5/21/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "ReferAFriendCollectionViewCell.h"

@interface ReferAFriendCollectionViewCell ()



@end

@implementation ReferAFriendCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2) - 50, 0, 100, 100)];
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor whiteColor];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, frame.size.width, 10)];
        self.label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    
    return self;
}

@end
