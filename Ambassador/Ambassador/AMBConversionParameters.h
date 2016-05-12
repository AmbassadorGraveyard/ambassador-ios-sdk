//
//  ConversionParameters.h
//  iOS_Framework
//
//  Created by Diplomat on 6/29/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMBConversionParameters : NSObject

@property (nonatomic, strong) NSNumber * mbsy_campaign;
@property (nonatomic, strong) NSString * mbsy_email;
@property (nonatomic, strong) NSNumber * mbsy_revenue;
@property (nonatomic, strong) NSString * mbsy_transaction_uid;
@property (nonatomic, strong) NSString * mbsy_event_data1;
@property (nonatomic, strong) NSString * mbsy_event_data2;
@property (nonatomic, strong) NSString * mbsy_event_data3;
@property (nonatomic, strong) NSNumber * mbsy_is_approved;

@end
