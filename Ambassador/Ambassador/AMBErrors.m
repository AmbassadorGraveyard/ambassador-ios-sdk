//
//  AMBErrors.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBErrors.h"

NSError* AMBINVNETOBJError(id sender) {
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

NSError* AMBSQLSAVEFAILError() {
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"SQL Save Failure", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"SQL INSERT query execution failed", nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBNOIDENT userInfo:usIn];
}

NSError* AMBNOPERMISSError(id sender) {
    NSString *localStr = [NSString stringWithFormat:@"The following object didn't have necessary permissions %@", sender];
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"Lacking Permission to Access Data", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(localStr, nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBNOPERMISS userInfo:usIn];
}

NSError* AMBINVSMSNUMError(NSMutableArray *badVals) {
    NSString *localStr = [NSString stringWithFormat:@"The following SMS Numbers are invalid: %@", badVals];
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid SMS Numbers", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(localStr, nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBINVSMSNUM userInfo:usIn];
}

NSError* AMBNOIDENTError() {
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"No Identify Object", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No Identify object found", nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBNOIDENT userInfo:usIn];
}

NSError* AMBINVLKDNAUTHError(NSString *msg) {
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"LinkedIn Authentication Error", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(msg, nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBINVLKDNAUTH userInfo:usIn];
}

NSError* AMBINVPARAMError(NSString *methodName) {
    NSString *localStr = [NSString stringWithFormat:@"The parameters are all required for: %@", methodName];
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid Method Parameters", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(localStr, nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBINVPARAM userInfo:usIn];
}

NSError* AMBNOVALError() {
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid Method Parameters", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Nil or unrecognizable retun value", nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBNOVAL userInfo:usIn];
}

NSError* AMBSQLINITFAILError(NSString *filePath) {
    NSString *msg = [NSString stringWithFormat:@"Filepath: %@", filePath];
    NSDictionary *usIn =    @{
                              NSLocalizedDescriptionKey: NSLocalizedString(@"SQL Initialization Failure", nil),
                              NSLocalizedFailureReasonErrorKey: NSLocalizedString(msg, nil),
                              NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"", nil)
                              };
    return [NSError errorWithDomain:@AMBErrorDomain code:AMBSQLINITFAIL userInfo:usIn];
}
