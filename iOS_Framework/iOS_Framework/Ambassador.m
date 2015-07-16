//
//  Ambassador.m
//  iOS_Framework
//
//  Created by Diplomat on 6/18/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Ambassador.h"
#import "Constants.h"
#import "Identify.h"
#import "Conversion.h"
#import "ConversionParameters.h"

@implementation Ambassador

#pragma mark - Static class variables
static NSString *APIKey;
static NSMutableDictionary *backEndData;
static bool showWelcomeScreen = false;
static NSTimer *conversionTimer;
static Identify *identify;
static Conversion *conversion;



#pragma mark - Object lifecycle
+ (Ambassador *)sharedInstance
{
    DLog();
    static Ambassador* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[Ambassador alloc] init];
    });
    
    return _sharedInsance;
}

- (void)dealloc
{
    DLog();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Class API method wrappers of instance API methods

//This was done to allow [Ambassador some_method]
//                                  vs
//                 [[Ambassador sharedInstance] some_method]
//
+ (void)runWithKey:(NSString *)key convertingOnLaunch:(ConversionParameters *)information
{
    DLog();
    [[Ambassador sharedInstance] runWithKey:key
                      convertingOnLaunch:information];
}

+ (void)presentRAFFromViewController:(UIViewController *)viewController
{
    DLog();
    [[Ambassador sharedInstance] presentRAFFromViewController:viewController];
}

+ (void)registerConversion:(ConversionParameters *)information
{
    DLog();
    [[Ambassador sharedInstance] registerConversion:information];
}



#pragma mark - Internal API methods
- (void)runWithKey:(NSString *)key convertingOnLaunch:(ConversionParameters *)information
{
    DLog();
    DLog(@"Begin listening for identify notification")
    
    //Listen for successful call to identify (we got a fingerprint back)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identifyCallback:)
                                                 name:AMB_IDENTIFY_NOTIFICATION_NAME
                                               object:nil];
    
#if DEBUG
    DLog(@"Removing user defaults for testing");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
    
    //Check if we have identify data. If not, the welcome may need to be shown
    //Could be set to no if not refered, the app was reinstalled but backend has
    //device id, etc.
    DLog(@"Checking for identify data");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AMB_IDENTIFY_STORAGE_KEY])
    {
        DLog(@"\tIdentify data was found");
    }
    else
    {
        showWelcomeScreen = true;
        DLog(@"\tIdentify data not found");
    }
    
    //Initialize class variables
    DLog(@"Initializing class variables");
    APIKey = key;
    conversionTimer = [NSTimer scheduledTimerWithTimeInterval:AMB_CONVERSION_FLUSH_TIME
                                                       target:self
                                                     selector:@selector(checkConversionQueue)
                                                     userInfo:nil
                                                      repeats:YES];
    identify = [[Identify alloc] init];
    conversion = [[Conversion alloc] init];
    [identify identify];
    DLog(@"Checking if conversion is made on app launch");
    if (information)
    {
        DLog(@"\tSending conversion on app launch");
        [self registerConversion:information];
    }
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    DLog();
}

- (void)registerConversion:(ConversionParameters *)information
{
    DLog();
    [conversion registerConversionWithParameters:information];
}



#pragma mark - Callback functions
- (void)identifyCallback:(NSNotification *)notifications
{
    DLog();
    __autoreleasing NSError *e;
    DLog(@"Seralizing identify data into NSData");
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:identify.identifyData
                                                          options:0
                                                            error:&e];
    if (!e)
    {
        DLog(@"Serialization successful, making network request");
        [self makeNetworkRequestToURL:AMB_INITIAL_BACKEND_REQUEST_URL withData:requestData];
    }
    else
    {
        DLog(@"Serialization unsuccessful");
        //TODO: Do we need to retry here or are we just in trouble?
        //      It shouldn't happen because we had a succesful serialization in
        //      the first place
    }
    
}



#pragma mark - Helper functions
- (void)checkConversionQueue
{
    DLog();
    [conversion sendConversions];
}

- (void)makeNetworkRequestToURL:(NSString *)url withData:(NSData *)data
{
    DLog();
    
    //Build the request
    DLog(@"Building the request with url %@", url);
    //TODO: there might be additional HTTP header fields to consider in production
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length]
               forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    //Make the call
    DLog(@"Making the data task call");
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data,
                                                          NSURLResponse *response,
                                                          NSError *error)
    {
        if (!error)
        {
            //TODO: there might be other acceptable status codes
            if (((NSHTTPURLResponse *)response).statusCode == 200)
            {
                DLog(@"Successful data task completion with status code %li and response data: %@",
                     (long)((NSHTTPURLResponse *)response).statusCode,
                     data);
            }
            else
            {
                DLog(@"Successful data task request BUT status code %li and response data: %@",
                     (long)((NSHTTPURLResponse *)response).statusCode,
                     data);
            }
        }
        else
        {
            DLog(@"Unsuccessful data task request with status code %li and error: %@",
                 (long)((NSHTTPURLResponse *)response).statusCode,
                 error.localizedDescription);
        }
    }];
    [dataTask resume];
}

@end
