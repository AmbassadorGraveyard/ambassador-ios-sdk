
//
//  AMBErrors.h
//  Ambassador
//
//  Created by Diplomat on 9/23/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#ifndef AMBErrors_h
#define AMBErrors_h

#define AMBErrorDomain      "AmbassadorErrorDomain"
#define AMBINVNETOBJ        1   /* Invalid Network Object */
#define AMBBADRESP          2   /* Non-200 Server Response */
#define AMBCDINVMOC         3   /* Core Data Error */

#import <Foundation/Foundation.h>

NSError* AMBINVETOBJError(id sender);
NSError* AMBBADRESPError(NSUInteger code, NSData *data);
NSError* AMBCDINVMOCError();

#endif /* AMBErrors_h */
