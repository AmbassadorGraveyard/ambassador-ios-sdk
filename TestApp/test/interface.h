//
//  interface.h
//  fileInterface
//
//  Created by Diplomat on 6/4/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface interface : NSObject

- (BOOL)setUpAmbassadorDocumentsDirectory;
- (NSMutableArray*)writeArray:(NSArray *)addArray toQueue:(NSString *)queueName;
- (NSMutableArray*)wipeArrayAtPath:(NSString *)path;
- (NSDictionary *)writeDictionary:(NSDictionary *)dictionary toQueue:(NSString *)dictionaryName;
- (NSString *)getPathDirectory;

@end
