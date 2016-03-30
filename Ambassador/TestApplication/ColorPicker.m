//
//  ColorPicker.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/24/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ColorPicker.h"
#import "UIColor+AMBColorValues.h"

@interface ColorPicker() <UITextFieldDelegate>

// IBOutlets
@property (nonatomic, strong) IBOutlet UIImageView * ivColorPicker;
@property (nonatomic, strong) IBOutlet UIView * currentColorView;
@property (nonatomic, strong) IBOutlet UIView * masterView;
@property (nonatomic, strong) IBOutlet UITextField * tfHexCode;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * masterMidConstraint;

// Private properties
@property (nonatomic, strong) UIColor * selectedColor;

@end


@implementation ColorPicker


#pragma mark - LifeCycle

- (instancetype)initWithColor:(NSString*)color {
    // Gets viewController from storyboard to present
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"colorPicker"];
    
    // Gets initial color to use
    self.selectedColor = [UIColor colorFromHexString:color];
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


#pragma mark - IBActions

- (IBAction)closeTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate colorPickerColorSaved:self.selectedColor];
}


#pragma mark - Touch Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self setValuesFromColorWithTouch:touch];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self setValuesFromColorWithTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch view] == self.ivColorPicker) {
        self.tfHexCode.text = [UIColor hexStringForColor:self.selectedColor];
    }
}


#pragma mark - TextField Delegate

- (void)textFieldDidChange {
    self.selectedColor = [UIColor colorFromHexString:self.tfHexCode.text];
    self.currentColorView.backgroundColor = self.selectedColor;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.masterMidConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.masterMidConstraint.constant = -100;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}


#pragma mark - UI Functions

- (void)setupUI {
    // Views
    self.masterView.layer.cornerRadius = 5;
    self.currentColorView.layer.cornerRadius = 5;
    self.currentColorView.layer.borderWidth = 0.6;
    self.currentColorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.currentColorView.backgroundColor = self.selectedColor;
    
    // Image Views
    self.ivColorPicker.layer.cornerRadius = self.ivColorPicker.frame.size.height/2;
    self.ivColorPicker.userInteractionEnabled = YES;
    
    // TextField
    self.tfHexCode.text = [UIColor hexStringForColor:self.selectedColor];
    [self.tfHexCode addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}


#pragma mark - Helper Functions

- (void)setValuesFromColorWithTouch:(UITouch*)touch {
    // Checks to see if the view being touched is the color picker image
    if ([touch view] == self.ivColorPicker) {
        CGPoint location = [touch locationInView:self.ivColorPicker];
        self.selectedColor = [self colorOfPoint:location];
        self.currentColorView.backgroundColor = self.selectedColor;
    }
}

- (UIColor *)colorOfPoint:(CGPoint)point{
    unsigned char pixel[4] = {0};
    
    // Works on getting rendering image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    // Grabs the pixel being touched
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    // Renders image based around pixel
    [self.ivColorPicker.layer renderInContext:context];
    
    // Creates color based on the individual pixel being touched
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
}

@end
