//
//  CustomFlow.m
//  AnalyticsApp
//
//  Created by Diplomat on 5/22/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import "CustomFlow.h"

@implementation CustomFlow

-(id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(36, 36);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if ([[UIScreen mainScreen] bounds].size.width > 189) {
            float padding = ([[UIScreen mainScreen] bounds].size.width - 189) / 2;
            self.sectionInset = UIEdgeInsetsMake(0, padding, 0, 0);
        }
        //self.headerReferenceSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 30);
        self.minimumLineSpacing = 15.0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

@end
