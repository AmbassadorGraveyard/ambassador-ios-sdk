//
//  AMBSurveySlider.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/29/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "AMBSurveySlider.h"

@interface AMBSurveySlider()

// IBOutlets
@property (nonatomic, weak) IBOutlet UILabel * lblTopNum;
@property (nonatomic, weak) IBOutlet UILabel * lblBottomNum;

// Private properties
@property (nonatomic) NSInteger highNum;
@property (nonatomic) NSInteger lowNum;
@property (nonatomic, strong) UIView * sliderArrow;
@property (nonatomic, strong) UILabel * lblScoreNum;
@property (nonatomic, strong) NSMutableArray * layerArray;

@end


@implementation AMBSurveySlider

CGFloat linePosition = 0;

// Function to tell the high num of the sliderView
- (void)setUpSliderWithHighNum:(NSInteger)highNum lowNum:(NSInteger)lowNum {
    self.highNum = highNum;
    self.lowNum = lowNum;
    self.lblTopNum.text = [NSString stringWithFormat:@"%li", (long)highNum];
    self.lblBottomNum.text = [NSString stringWithFormat:@"%li", (long)lowNum];
    self.backgroundColor = self.superview.backgroundColor;
    self.layerArray = [[NSMutableArray alloc] init];
}

- (void)drawRect:(CGRect)rect {
    [self drawSurveyGrid];
    [self drawSliderArrow];
}

- (void)drawSurveyGrid {
    // Grabs the beginning and end point of each horizontal line
    CGFloat beginning = self.frame.size.width/2 - 25;
    CGFloat mid = self.frame.size.width/2 - 4;
    CGFloat newMid = self.frame.size.width/2 + 4;
    CGFloat end = self.frame.size.width/2 + 25;
    
    for (int i = 0; i < 11; i++) {
        // Get the new Y (vertical position) for each line
        CGFloat newY = i == 0 ? 0 : [self linePostition];
        
        // Creats a path for horizontal line, left of the center
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(beginning, newY)];
        [path addLineToPoint:CGPointMake(mid, newY)];
        
        // Creates a shape based on the path
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
        shapeLayer.lineWidth = 0.7;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [shapeLayer setName:[NSString stringWithFormat:@"%f", newY]];
        
        // Add the layer to the grid
        [self.layer addSublayer:shapeLayer];
        
        // Insert layer in array so that the index reflets the number
        [self.layerArray insertObject:shapeLayer atIndex:0];

        // Resets path for horizontal line, right of the center
        [path moveToPoint:CGPointMake(newMid, newY)];
        [path addLineToPoint:CGPointMake(end, newY)];
        
        // Resets the shapes path for re-use
        shapeLayer.path = path.CGPath;
        
        // Adds new layer
        [self.layer addSublayer:shapeLayer];
    }
    
    // Get the center of the screen of the view
    CGFloat centerPoint = self.frame.size.width/2;
    
    // Draws line down the middle of the grid
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(centerPoint, -10)];
    [path addLineToPoint:CGPointMake(centerPoint, self.frame.size.height + 10)];
    
    // Creates a 'shape' for the path and add the layer for the view
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.layer addSublayer:shapeLayer];
}

- (void)drawSliderArrow {
    CGFloat sizeNum = 70;
    
    // Init sliderArrow view
    self.sliderArrow = [[UIView alloc] initWithFrame: CGRectMake(self.frame.size.width/2 - (sizeNum * 1.5), self.frame.size.height/2 - (sizeNum/2), sizeNum, sizeNum)];
    [self addSubview:self.sliderArrow];
    
    // Create a circle with border
    UIView * circle = [[UIView alloc] initWithFrame: CGRectMake(0, 0, sizeNum, sizeNum)];
    circle.backgroundColor = self.backgroundColor;
    circle.layer.borderColor = [UIColor whiteColor].CGColor;
    circle.layer.borderWidth = 4;
    circle.layer.cornerRadius = sizeNum/2;
    [self.sliderArrow addSubview:circle];
    
    // Get points for triangle drawing
    CGFloat circleCenter = circle.frame.size.height/2;
    CGFloat arrowHeightDifference = 25;
    
    // Create full path for triangle
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(circle.center.x, circleCenter - arrowHeightDifference)];
    [trianglePath addLineToPoint:CGPointMake(circle.center.x, circleCenter + arrowHeightDifference)];
    [trianglePath addLineToPoint:CGPointMake(circle.center.x + 70, circleCenter)];
    [trianglePath addLineToPoint:CGPointMake(circle.center.x, circleCenter - arrowHeightDifference)];
    
    // Creates a triangle shape based on the path
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = trianglePath.CGPath;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    shape.fillColor = [UIColor whiteColor].CGColor;

    // Insert the triangle layer below the circle layer
    [self.sliderArrow.layer insertSublayer:shape below:circle.layer];
    
    // Sets up the current score number label
    self.lblScoreNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sizeNum, sizeNum)];
    self.lblScoreNum.textAlignment = NSTextAlignmentCenter;
    self.lblScoreNum.textColor = [UIColor whiteColor];
    self.lblScoreNum.font = [UIFont systemFontOfSize:36];
    [self.sliderArrow addSubview:self.lblScoreNum];
    self.lblScoreNum.text = @"5";
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     UITouch *touch = [touches anyObject];
    [self moveWithTouch:touch];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self moveWithTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self snapToNearestLine];
}

- (void)moveWithTouch:(UITouch*)touch {
    CGPoint location = [touch locationInView:self];
    BOOL pointerInBounds = location.y >= 0 && location.y <= self.frame.size.height;
    
    // Checks to see if the view being touched the slider view and that is in bounds
    if (([touch view] == self || [self isInSliderView:[touch view]]) && pointerInBounds) {
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
                self.sliderArrow.center = CGPointMake(self.sliderArrow.center.x, location.y);
                [self updateScoreLabel];
            }];
        } completion:nil];
        
    }
}

// Get the veritical spacing of each line based on the top num in the survey
- (CGFloat)linePostition {
    CGFloat spacing = self.frame.size.height/10;
    linePosition += spacing;
    
    return linePosition;
}

// Checks to see if the touch is in a subview of the slider
- (BOOL)isInSliderView:(UIView *)touchView {
    for (UIView *view in [self.sliderArrow subviews]) {
        if (touchView == view) {
            return YES;
        }
    }
    
    return NO;
}

- (void)snapToNearestLine {
    // Gets the y value of the closest horizontal line
    NSInteger closestLayerY = [[self closestLayer].name intValue];

    // Animate the slider to the nearest line
    [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            self.sliderArrow.center = CGPointMake(self.sliderArrow.center.x, closestLayerY);
            [self updateScoreLabel];
        }];
    } completion:nil];
}

- (CAShapeLayer *)closestLayer {
    // Set the smallestDifference to 1000 because its so high it will have to change
    CGFloat smallestDifference = 1000;
    
    CAShapeLayer *layer = nil;
    
    // Goes through each line drawn in the grid
    for (CAShapeLayer *currentLayer in self.layer.sublayers) {
        // We only want to check horizontal lines which have been named with their Y
        if (![currentLayer.name isEqualToString:@""]) {
            // Grab the Y value based on name
            CGFloat y = [currentLayer.name floatValue];
            
            // Get the differnce between the slider y and line y
            CGFloat currentDifference = self.sliderArrow.center.y - y;
            
            // If the distance between is smaller than the currently smallest, we reset it to the new smallest
            if (fabs(currentDifference) < smallestDifference) {
                smallestDifference = currentDifference;
                layer = currentLayer;
            }
        }
    }
    
    return layer;

}

- (void)updateScoreLabel {
    // Updates the score label based on the position of the arrow
    CAShapeLayer *layer = [self closestLayer];
    self.lblScoreNum.text = [NSString stringWithFormat:@"%li", (long)[self.layerArray indexOfObject:layer]];
}

@end
