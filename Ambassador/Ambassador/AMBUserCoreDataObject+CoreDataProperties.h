//
//  AMBUserCoreDataObject+CoreDataProperties.h
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AMBUserCoreDataObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface AMBUserCoreDataObject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *ambUserNetworkObject;

@end

NS_ASSUME_NONNULL_END
