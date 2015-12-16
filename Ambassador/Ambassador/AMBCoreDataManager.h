//
//  AMBCoreDataManager.h
//  Ambassador
//
//  Created by Jake Dunahee on 12/16/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBCoreDataManager : NSObject

+ (void)saveNewObjectToCoreDataWithEntityName:(NSString *)entityTypeToSave valuesToSave:(NSDictionary*)valuesDict;
+ (NSMutableArray*)getAllEntitiesFromCoreDataWithEntityName:(NSString*)entityName alphabetizeByProperty:(NSString*)property;
+ (NSMutableArray*)getAllEntitiesFromCoreDataWithEntityName:(NSString *)entityName;

@end
