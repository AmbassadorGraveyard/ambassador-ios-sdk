//
//  RAFShareScreen.h
//  iOS_Framework
//
//  Created by Diplomat on 7/16/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RAFParameters.h"

@interface RAFShareScreen : UIViewController

@property (nonatomic, strong) RAFParameters * rafParameters;

- (id)initWithShortURL:(NSString *)url shortCode:(NSString *)shortCode;

@end
