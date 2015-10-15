//
//  AMBErrors.h
//  Ambassador
//
//  Created by Diplomat on 10/15/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#ifndef AMBErrors_h
#define AMBErrors_h

#define AMBErrorDomain      "AmbassadorErrorDomain"
#define AMBINVNETOBJ        1   /* Invalid Network Object */
#define AMBBADRESP          2   /* Non-200 Server Response */
#define AMBCDINVMOC         3   /* Core Data Error */
#define AMBNOPERMISS        4   /* Lacking Permission to Access Data */
#define AMBINVSMSNUM        5   /* Invalid SMS Number */
#define AMBNOIDENT          6   /* No Identify Error */
#define AMBINVLKDNAUTH      7   /* LinkedIn Authentication Error */
#define AMBINVPARAM         8   /* Invalid Method Parameters */
#define AMBNOVAL            9   /* No Value Return */

#import <Foundation/Foundation.h>

NSError* AMBINVETOBJError(id sender);
NSError* AMBBADRESPError(NSUInteger code, NSData *data);
NSError* AMBCDINVMOCError();
NSError* AMBNOPERMISSError(id sender);
NSError* AMBINVSMSNUMError(NSMutableArray *badVals);
NSError* AMBNOIDENTError();
NSError* AMBINVLKDNAUTHError(NSString *msg);
NSError* AMBINVPARAMError(NSString *methodName);
NSError* AMBNOVALError();

#endif /* AMBErrors_h */
