//
//  ThemeHandler.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RAFItem.h"

@interface ThemeHandler : NSObject

+ (void)saveTheme:(RAFItem*)rafTheme;
+ (void)saveImage:(UIImage*)image forTheme:(RAFItem*)theme;
+ (void)deleteRafItem:(RAFItem*)rafItem;
+ (NSString *)getDocumentsPathWithName:(NSString*)themeName;
+ (NSMutableDictionary *)dictionaryFromPlist:(RAFItem*)item;
+ (NSMutableDictionary *)getGenericTheme;
+ (UIImage *)getImageForRAF:(RAFItem*)item;

@end
