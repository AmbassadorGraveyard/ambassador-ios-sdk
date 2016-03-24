//
//  ThemeHandler.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAFItem.h"

@interface ThemeHandler : NSObject

+ (void)saveNewTheme:(RAFItem*)rafTheme;
+ (void)deleteRafItem:(RAFItem*)rafItem;
+ (NSString *)getDocumentsPathWithName:(NSString*)themeName;
+ (NSMutableDictionary *)dictionaryFromPlist:(RAFItem*)item;
+ (NSMutableDictionary *)getGenericTheme;

@end
