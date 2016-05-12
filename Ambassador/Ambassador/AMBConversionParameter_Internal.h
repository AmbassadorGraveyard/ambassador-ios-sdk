//
//  AMBConversionParameter_Internal.h
//  Ambassador
//
//  Created by Jake Dunahee on 12/18/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBConversionParameters.h"
#import "AMBConversionParametersEntity.h"

@interface AMBConversionParameters()

@property (nonatomic, strong) NSArray * propertyArray;

- (id)initWithEntity:(AMBConversionParametersEntity *)entity;
- (instancetype)initWithProperties:(NSDictionary *)properties;
- (NSError*)checkForError;
- (NSString*)getShortCode;
- (NSDictionary*)propertyDictionary;
+ (BOOL)isStringProperty:(NSString*)propertyName;
+ (BOOL)isBoolProperty:(NSString*)propertyName;

@end
