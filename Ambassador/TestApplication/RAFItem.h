//
//  RAFItem.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CampaignObject.h"

@interface RAFItem : NSObject

@property (nonatomic, strong) NSString * rafName;
@property (nonatomic, strong) NSString * plistFullName;
@property (nonatomic, strong) NSData * xmlFileData;
@property (nonatomic, strong) NSDate * dateCreated;
@property (nonatomic, strong) NSMutableDictionary * plistDict;
@property (nonatomic, strong) CampaignObject * campaign;
@property (nonatomic, strong) NSString * imageFilePath;

- (instancetype)initWithName:(NSString*)name plistDict:(NSMutableDictionary*)dict xmlFileData:(NSData *)xmlData;

@end
