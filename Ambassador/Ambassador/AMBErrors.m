//
//  AMBErrors.m
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBErrors.h"

NSError* AMBINVETOBJError(id sender) {
    NSString *recStr = [NSString stringWithFormat:@"Check the class documentation for %@.", NSStringFromClass([sender class])];
    NSDictionary *usIn =    @{
                                NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid Network Object", nil),
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"There are necessary required properties that are unset or set incorrectly", nil),
                                NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(recStr, nil)
                            };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBINVNETOBJ userInfo:usIn];
}

NSError* AMBBADRESPError(NSUInteger code, NSData *data) {
    NSString *recStr = [NSString stringWithFormat:@"The server returned code %ld, with response %@", (unsigned long)code, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    NSDictionary *usIn =    @{
                                NSLocalizedDescriptionKey: NSLocalizedString(@"Bad Network Response", nil),
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"There was a non-200 server response", nil),
                                NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(recStr, nil)
                            };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBBADRESP userInfo:usIn];
}

NSError* AMBCDINVMOCError() {
    NSDictionary *usIn =    @{
                                NSLocalizedDescriptionKey: NSLocalizedString(@"Core Data Error", nil),
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The managed object context was nil", nil),
                                NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                            };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBCDINVMOC userInfo:usIn];
}
