//
//  AMBBulkShareHelper.m
//  Ambassador
//
//  Created by Jake Dunahee on 10/26/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBBulkShareHelper.h"
#import "AMBContact.h"

@implementation AMBBulkShareHelper

+ (NSMutableArray *)validatedEmails:(NSArray *)contacts {
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    
    for (AMBContact *contact in contacts) {
        NSString *email = contact.value;
        if ([AMBBulkShareHelper isValidEmail:email]) { [validSet addObject:email]; } // Checks for valid email before adding it to the list
    }
    
    return validSet;
}

+ (NSMutableArray *)validatedPhoneNumbers:(NSArray *)contacts {
    NSMutableArray *validSet = [[NSMutableArray alloc] init];
    
    for (AMBContact *contact in contacts) {
        NSString *number = [AMBBulkShareHelper stripPhoneNumber:contact.value];
        
        if ([AMBBulkShareHelper isValidPhoneNumber:number]) {
            [validSet addObject:number];
        }
    }
    
    return validSet;
}
                            
+ (BOOL)isValidEmail:(NSString*)emailAddress {
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    
    return [emailTest evaluateWithObject:emailAddress];
}

+ (BOOL)isValidPhoneNumber:(NSString*)phoneNumber {
    if (phoneNumber.length == 11 || phoneNumber.length == 10 || phoneNumber.length == 7) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*)stripPhoneNumber:(NSString*)phoneNumber {
    return [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

+ (NSArray*)shareTrackPayload:(NSArray*)contactList shareType:(AMBSocialServiceType)socialType {
    AMBShareTrackNetworkObject *shareTrackObject = [[AMBShareTrackNetworkObject alloc] init];
    shareTrackObject.short_code = [AMBValues getUserURLObject].short_code;
    shareTrackObject.social_name = [AMBOptions serviceTypeStringValue:socialType];
    
    NSMutableArray *trackingObjects = ([contactList count] > 0) ? [[NSMutableArray alloc] init] : [NSMutableArray arrayWithObject:[shareTrackObject toDictionary]];
    
    for (NSString *contact in contactList) {
        switch (socialType) {
            case AMBSocialServiceTypeSMS:
                shareTrackObject.recipient_username = contact;
                break;
            case AMBSocialServiceTypeEmail:
                shareTrackObject.recipient_email = contact;
                break;
            default:
                break;
        }
        
        [trackingObjects addObject:[shareTrackObject toDictionary]];
    }
    
    return trackingObjects;
}
                            

@end
