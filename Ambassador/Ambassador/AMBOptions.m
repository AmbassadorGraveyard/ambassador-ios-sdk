//
//  AMBOptions.m
//  Ambassador
//
//  Created by Diplomat on 10/21/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBOptions.h"

NSString* socialServiceTypeStringVal(AMBSocialServiceType type) {
    switch (type) {
        case AMBSocialServiceTypeEmail:
            return @"email";
            break;
        case AMBSocialServiceTypeSMS:
            return @"sms";
            break;
        case AMBSocialServiceTypeTwitter:
            return @"twitter";
            break;
        case AMBSocialServiceTypeLinkedIn:
            return @"linkedin";
            break;
        case AMBSocialServiceTypeFacebook:
            return @"facebook";
            break;
        default:
            return nil;
            break;
    }
}

NSString* sqlStorageTypeStringVal(AMBSQLStorageType type) {
    switch (type) {
        case AMBSQLStorageTypeConversions:
            return @"conversions";
            break;
        default:
            break;
    }
}

NSString* sqlUpdateTypeStringVal(AMBSQLUpdateType type) {
    switch (type) {
        case AMBSQLUpdateTypeInsert:
            return @"INSERT";
            break;
        case AMBSQLUpdateTypeDelete:
            return @"DELETE";
            break;
        default:
            break;
    }
}
