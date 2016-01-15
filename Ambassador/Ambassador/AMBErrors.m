//
//  AMBErrors.m
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBErrors.h"

@implementation AMBErrors

+ (void)conversionError:(NSInteger)statusCode errorData:(NSData*)data {
    NSLog(@"[Ambassador] Error Sending Conversion - Status Code=%li Failure Reason=%@", (long)statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
}

@end
