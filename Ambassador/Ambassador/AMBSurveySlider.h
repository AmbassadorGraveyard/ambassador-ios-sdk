//
//  AMBSurveySlider.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMBSurveySlider;

// Class protocol
@protocol AMBSurveySliderDelegate <NSObject>

- (void)AMBSurveySlider:(AMBSurveySlider *)surveySlider valueSelected:(NSString *)value;

@end


// Class interface
@interface AMBSurveySlider : UIView

@property (nonatomic, weak) id<AMBSurveySliderDelegate> delegate;
@property (nonatomic, strong) UIColor * contentColor;

- (void)setUpSliderWithHighNum:(NSInteger)highNum lowNum:(NSInteger)lowNum;

@end
