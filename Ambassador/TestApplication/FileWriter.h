//
//  FileWriter.h
//  Ambassador
//
//  Created by Jake Dunahee on 4/14/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum readMeType {
    ReadmeTypeIdentify,
    ReadmeTypeConversion,
    ReadmeTypeRAF
} READMETypes;

@interface FileWriter : NSObject

+ (NSString *)objcAppDelegateFileWithInsert:(NSString *)insert;
+ (NSString *)swiftAppDelegateFileWithInsert:(NSString *)insert;
+ (NSString *)javaMyApplicationFileWithInsert:(NSString *)insert;
+ (NSString *)readMeForRequest:(READMETypes)readmeType;
+ (NSString *)objcViewControllerWithInsert:(NSString *)insert;
+ (NSString *)swiftViewControllerWithInsert:(NSString *)insert;
+ (NSString *)javaActivityWithInsert:(NSString *)insert;
+ (NSString *)documentsPath;

@end
