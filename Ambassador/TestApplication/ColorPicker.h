//
//  ColorPicker.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/24/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate <NSObject>

- (void)colorPickerColorSaved:(UIColor*)color;

@end


@interface ColorPicker : UIViewController

@property (nonatomic, weak) id<ColorPickerDelegate> delegate;

- (instancetype)initWithColor:(NSString*)color;

@end
