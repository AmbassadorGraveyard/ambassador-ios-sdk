//
//  AMB_RAF_ShareServiceCell.m
//  Ambassador
//
//  Created by Diplomat on 5/28/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "AMB_RAF_ShareServiceCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation AMB_RAF_ShareServiceCell

- (id)init
{
    if ([super init])
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([super initWithCoder:aDecoder])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.logo = [[UILabel alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.logo];
    [self.logo setFont:[UIFont systemFontOfSize:8]];
    self.contentView.backgroundColor = [UIColor greenColor];
}

@end
