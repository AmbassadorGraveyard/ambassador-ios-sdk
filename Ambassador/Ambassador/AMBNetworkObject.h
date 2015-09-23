//
//  AMBNetworkObject.h
//  networking
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBErrors.h"

@interface AMBNetworkObject : NSObject
- (NSMutableDictionary *)dictionaryForm;
- (NSError *)validate;
@end
