//
//  AMBShareServiceCellTests.m
//  Ambassador
//
//  Created by Jake Dunahee on 1/26/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AMBShareServiceCell.h"
#import "AMBValues.h"

@interface AMBShareServiceCell (Test)

@property (nonatomic, strong) IBOutlet UIImageView * ivLogo;
@property (nonatomic, strong) IBOutlet UIView * logoBackground;
@property (nonatomic, strong) IBOutlet UILabel * lblTitle;

- (void)setUpCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon;
- (void)setupBorderCellWithTitle:(NSString*)title backgroundColor:(UIColor*)backgroundColor icon:(UIImage*)imageIcon borderColor:(UIColor*)borderColor;

@end


@interface AMBShareServiceCellTests : XCTestCase

@property (nonatomic, strong) AMBShareServiceCell * cell;

@end

@implementation AMBShareServiceCellTests

- (void)setUp {
    [super setUp];
    if (!self.cell) {
        self.cell = [[AMBShareServiceCell alloc] init];
        self.cell.lblTitle = [[UILabel alloc] init];
        self.cell.logoBackground = [[UIView alloc] init];
        self.cell.ivLogo = [[UIImageView alloc] init];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Setup Tests

- (void)testSetUpRegularCell {
    // GIVEN
    NSString *title = @"TestTitle";
    UIColor *backgroundColor = [UIColor whiteColor];
    UIImage *image = [AMBValues imageFromBundleWithName:@"fail" type:@"png" tintable:NO];
  
    // WHEN
    [self.cell setUpCellWithTitle:title backgroundColor:backgroundColor icon:image];
    
    // THEN
    XCTAssertEqualObjects(title, self.cell.lblTitle.text);
    XCTAssertEqualObjects(backgroundColor, self.cell.logoBackground.backgroundColor);
    XCTAssertEqualObjects(image, self.cell.ivLogo.image);
}

- (void)testSetUpBorderCell {
    // GIVEN
    NSString *title = @"TestTitle";
    UIColor *backgroundColor = [UIColor whiteColor];
    UIImage *image = [AMBValues imageFromBundleWithName:@"fail" type:@"png" tintable:NO];
    UIColor *borderColor = [UIColor greenColor];
    
    // WHEN
    [self.cell setupBorderCellWithTitle:title backgroundColor:backgroundColor icon:image borderColor:borderColor];
    
    // THEN
    XCTAssertEqualObjects(title, self.cell.lblTitle.text);
    XCTAssertEqualObjects(backgroundColor, self.cell.logoBackground.backgroundColor);
    XCTAssertEqualObjects(image, self.cell.ivLogo.image);
    XCTAssertEqualObjects(borderColor.CGColor, self.cell.logoBackground.layer.borderColor);
}

- (void)testSetUpCellType {
    // GIVEN
    NSArray *cellTypes = @[[NSNumber numberWithInt:Facebook], [NSNumber numberWithInt:Twitter], [NSNumber numberWithInt:LinkedIn], [NSNumber numberWithInt:SMS], [NSNumber numberWithInt:Email], [NSNumber numberWithInt:None]];
    NSArray *titles = @[@"Facebook", @"Twitter", @"LinkedIn", @"SMS", @"Email", @"Unavailable"];
    
    BOOL isPassing = YES;
    
    // WHEN
    for (int i = 0; i < [cellTypes count]; i++) {
        [self.cell setUpCellWithCellType:[cellTypes[i] intValue]];
        if (![self.cell.lblTitle.text isEqualToString:titles[i]]) {
            isPassing = NO;
        }
    }
    
    // THEN
    XCTAssertTrue(isPassing);
}

@end
