//
//  Identify.h
//  iOS_Framework
//
//  Created by Diplomat on 6/19/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Identify : NSObject
- (void)identifyWithURL:(NSString *)url completion:(void (^)(NSMutableDictionary *r, NSError *e))completion;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end