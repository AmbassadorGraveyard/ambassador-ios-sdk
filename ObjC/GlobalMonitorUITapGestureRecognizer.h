//
//  GlobalMonitorUITapGestureRecognizer.h
//  ObjC
//
//  Created by Diplomat on 5/14/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface GlobalMonitorUITapGestureRecognizer : UITapGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) enableVisualizer;
- (id)initWithConversionItems:(NSMutableDictionary*)conversionItems andReferAFriendItems:(NSMutableDictionary*)referAFriendItems;
@property NSMutableDictionary* conversionItems;
@property NSMutableDictionary* referAFreindLauchItems;

@end
