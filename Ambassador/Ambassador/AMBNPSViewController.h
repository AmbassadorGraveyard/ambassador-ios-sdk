//
//  AMBNPSViewController.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/7/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBNPSViewController : UIViewController

@property (nonatomic, strong) UIColor * mainBackgroundColor;
@property (nonatomic, strong) UIColor * contentColor;
@property (nonatomic, strong) UIColor * buttonColor;

- (id)initWithPayload:(NSDictionary*)payloadDict;

@end
