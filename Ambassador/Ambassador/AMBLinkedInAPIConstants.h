//
//  LinkedInAPIConstants.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#ifndef RAF_LinkedInAPIConstants_h
#define RAF_LinkedInAPIConstants_h

#import <Foundation/Foundation.h>

// Keys in JSON responses from LinkedIn
extern NSString * const AMB_LKDN_ERROR_DICT_KEY; // During first auth step
extern NSString * const AMB_LKDN_CODE_DICT_KEY; // During first auth step
extern NSString * const AMB_LKDN_EXPIRES_DICT_KEY; // During second auth step
extern NSString * const AMB_LKDN_OAUTH_TOKEN_KEY; // Key for token in userdefaults

extern NSString * const AMB_LKDN_COMMENT_DICT_KEY;
extern NSString * const AMB_LKDN_VISIBILITY_DICT_KEY;

// Urls
extern NSString * const AMB_LKDN_AUTH_URL;
extern NSString * const AMB_LKDN_AUTH_CALLBACK_URL;
extern NSString * const AMB_LKDN_REQUEST_OAUTH_TOKEN_URL;
extern NSString * const AMB_LKDN_SHARE_URL;

NSString* AMBlkdnBuildRequestTokenHTTPBody(NSString* key);

#endif
