//
//  LinkedInAPIConstants.h
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#ifndef RAF_LinkedInAPIConstants_h
#define RAF_LinkedInAPIConstants_h

#import <Foundation/Foundation.h>

// Keys in JSON responses from LinkedIn
extern NSString * const LKDN_ERROR_DICT_KEY; // During first auth step
extern NSString * const LKDN_CODE_DICT_KEY; // During first auth step
extern NSString * const LKDN_EXPIRES_DICT_KEY; // During second auth step

// Urls
extern NSString * const LKDN_AUTH_URL;
extern NSString * const LKDN_AUTH_CALLBACK_URL;
extern NSString * const LKDN_REQUEST_OAUTH_TOKEN_URL;

NSString* lkdnBuildRequestTokenHTTPBody(NSString* key);

#endif
