//
//  Ambassador.m
//  test
//
//  Created by Diplomat on 6/1/15.
//  Copyright (c) 2015 Ambassador. All rights reserved.
//

#import "Constants.h"
#import "Ambassador.h"
#import "Identify.h"
#import "Conversion.h"
#import "Promise.h"
#import "CutomTabBarController.h"
#import "TestWelcomeViewController.h"
//TODO: Import the view controllers


@implementation Ambassador

#pragma mark - Singleton instantiation
+ (Ambassador *)sharedInstance
{
    //TODO: REMOVE THESE FOR PRODUCTION
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    static Ambassador* _sharedInsance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInsance = [[Ambassador alloc] init];
    });
    
    return _sharedInsance;
}


#pragma mark - Static class variables
static Identify *identify;
static Conversion *conversion;
static NSString *APIKey;
static NSMutableDictionary *preferences;
static bool showWelcomeScreen = false;
//TODO: add the view controllers


- (NSMutableDictionary *)getPreferencesData
{
    return preferences;
}

#pragma mark - API functions
- (void)setAPIKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* userDefaultsAPIKey = [defaults stringForKey:@"Ambassakey"];
    if (!userDefaultsAPIKey)
    {
        //TODO: API key set
        showWelcomeScreen = true;
    }
    [defaults setObject:key forKey:@"Ambassakey"];
    [defaults synchronize];
    APIKey = key;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPreferences)
                                                 name:JSONCompletedNotificationName
                                               object:nil];
    //Initialize the non-UI classes
    identify = [[Identify alloc] init];
    conversion = [[Conversion alloc] init];
    [identify identify];
    
}

-(void)getPreferences
{
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://localhost:3000/welcome"]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"Network error occured during request for preferences\n\n %@", error);
            return;
        }
        
        __autoreleasing NSError *e;
        NSMutableDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&e];
        if (e)
        {
            NSLog(@"JSON error occured while trying to parse preferences\n\n %@" ,e);
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:@"AmbassaUIPreferences"];
        NSLog(@"%@", jsonData);
        preferences = jsonData;
        
        if (showWelcomeScreen) {
            [self presentWelcomeScreenFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
        
    }] resume];
}

- (void)registerConversion
{
    [conversion registerConversion];
}

- (void)registerConversionWithEmail:(NSString *)email
{
    [conversion registerConversionWithEmail:email];
}

- (void)presentWelcomeScreenFromViewController:(UIViewController *)viewController
{
    TestWelcomeViewController* vc = [[TestWelcomeViewController alloc] init];
    NSDictionary *color = [NSDictionary  dictionaryWithDictionary:preferences[@"backgroundColor"]];
    float red = [(NSNumber *)color[@"red"] floatValue];
    float green = [(NSNumber *)color[@"green"] floatValue];
    float blue = [(NSNumber *)color[@"blue"] floatValue];
    
    vc.accentColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
    
    vc.view.backgroundColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)presentRAFFromViewController:(UIViewController *)viewController
{
    CutomTabBarController* vc = [[CutomTabBarController alloc] init];
    [viewController presentViewController:vc animated:YES completion:nil];
}

@end
