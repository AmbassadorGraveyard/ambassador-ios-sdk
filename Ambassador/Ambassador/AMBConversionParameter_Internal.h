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

- (id)initWithEntity:(AMBConversionParametersEntity *)entity;
- (NSError*)checkForError;
- (NSString*)getShortCode;
- (NSDictionary*)propertyDictionary;

@end
