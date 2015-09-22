//
//  LinkedInAPIConstants.m
//  RAF
//
//  Created by Diplomat on 7/27/15.
//  Copyright (c) 2015 ZFERRAL, INC (dba Ambassador Software). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBLinkedInAPIConstants.h"

// Keys in JSON responses from LinkedIn
NSString * const AMB_LKDN_ERROR_DICT_KEY = @"error";
NSString * const AMB_LKDN_CODE_DICT_KEY = @"code";
NSString * const AMB_LKDN_EXPIRES_DICT_KEY = @"expires_in";
NSString * const AMB_LKDN_OAUTH_TOKEN_KEY = @"access_token";

NSString * const AMB_LKDN_COMMENT_DICT_KEY = @"comment";
NSString * const AMB_LKDN_VISIBILITY_DICT_KEY = @"visibility";

// Urls
NSString * const AMB_LKDN_AUTH_URL = @"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=***REMOVED***&redirect_uri=http://localhost:2999/&state=987654321&scope=r_basicprofile%20w_share";
NSString * const AMB_LKDN_AUTH_CALLBACK_URL = @"http://localhost:2999/";
NSString * const AMB_LKDN_REQUEST_OAUTH_TOKEN_URL = @"https://www.linkedin.com/uas/oauth2/accessToken";
NSString * const AMB_LKDN_SHARE_URL = @"https://api.linkedin.com/v1/people/~/shares?format=json";

NSString* AMBlkdnBuildRequestTokenHTTPBody(NSString* key)
{
    return [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=http://localhost:2999/&client_id=***REMOVED***&client_secret=***REMOVED***", key];
}
