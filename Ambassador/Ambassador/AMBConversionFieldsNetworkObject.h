//
//  AMBConversionFieldsNetworkObject.h
//  Ambassador
//
//  Created by Diplomat on 9/25/15.
//  Copyright © 2015 Ambassador. All rights reserved.
//

#import "AMBNetworkObject.h"

@interface AMBConversionFieldsNetworkObject : AMBNetworkObject
@property (nonatomic, strong) NSString *mbsy_campaign;
@property (nonatomic, strong) NSString *mbsy_email;
@property (nonatomic, strong) NSString *mbsy_first_name;
@property (nonatomic, strong) NSString *mbsy_last_name;
@property BOOL mbsy_email_new_ambassador;
@property (nonatomic, strong) NSString *mbsy_uid;
@property (nonatomic, strong) NSString *mbsy_custom1;
@property (nonatomic, strong) NSString *mbsy_custom2;
@property (nonatomic, strong) NSString *mbsy_custom3;
@property BOOL mbsy_auto_create;
@property (nonatomic, strong) NSNumber *mbsy_revenue;
@property BOOL mbsy_deactivate_new_ambassador;
@property (nonatomic, strong) NSString *mbsy_transaction_uid;
@property (nonatomic, strong) NSString *mbsy_add_to_group_id;
@property (nonatomic, strong) NSString *mbsy_event_data1;
@property (nonatomic, strong) NSString *mbsy_event_data2;
@property (nonatomic, strong) NSString *mbsy_event_data3;
@property BOOL mbsy_is_approved;
@end
