//
//  RAFCustomizer.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/23/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAFItem.h"

@protocol RAFCustomizerDelegate <NSObject>

- (void)RAFCustomizerSavedRAF:(RAFItem*)rafItem;

@end


@interface RAFCustomizer : UIViewController

@property (nonatomic, strong) RAFItem * rafItem;
@property (nonatomic, weak) id<RAFCustomizerDelegate> delegate;

@end
