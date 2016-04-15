//
//  FileWriter.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/14/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "FileWriter.h"
#import "DefaultsHandler.h"
#import "ValuesHandler.h"

@implementation FileWriter

+ (NSString *)objcAppDelegateFileWithInsert:(NSString *)insert {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"    [AmbassadorSDK runWithUniversalToken:\"%@\" universalID:\"%@\"]; \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    // Builds Objective-C implementation file
    NSMutableString *objectiveCString = [[NSMutableString alloc] init];
    [objectiveCString appendString: @"#import \"AppDelegate.h\" \n"];
    [objectiveCString appendString: @"#import <Ambassador/Ambassador.h> \n\n"];
    [objectiveCString appendString: @"@interface AppDelegate () \n\n"];
    [objectiveCString appendString: @"@end \n\n"];
    [objectiveCString appendString: @"@implementation AppDelegate \n\n"];
    [objectiveCString appendString: @"- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions { \n"];
    [objectiveCString appendString: runWithKeysString];
    [objectiveCString appendString:insert];
    [objectiveCString appendString:@"    return YES; \n"];
    [objectiveCString appendString:@"} \n\n"];
    [objectiveCString appendString: @"@end"];
    
    return objectiveCString;
}

+ (NSString *)swiftAppDelegateFileWithInsert:(NSString *)insert {
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithUniversalToken(\"%@\", universalID: \"%@\") \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    // Builds Swift file
    NSMutableString *swiftString = [[NSMutableString alloc] init];
    [swiftString appendString:@"import UIKit \n\n"];
    [swiftString appendString:@"@UIApplicationMain"];
    [swiftString appendString:@"class AppDelegate: UIResponder, UIApplicationDelegate { \n\n"];
    [swiftString appendString:@"    var window: UIWindow? \n\n\n"];
    [swiftString appendString:@"    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool { \n"];
    [swiftString appendString:runWithKeysString];
    [swiftString appendString:insert];
    [swiftString appendString:@"        return true \n"];
    [swiftString appendString:@"    } \n"];
    [swiftString appendString:@"}"];
    
    return swiftString;
}

+ (NSString *)javaMyApplicationFileWithInsert:(NSString *)insert {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithKeys(this, \"SDKToken %@\", \"%@\"); \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    // Builds Java file
    NSMutableString *javaString = [[NSMutableString alloc] init];
    [javaString appendString:@"package com.example.example; \n\n"];
    [javaString appendString:@"import android.app.Application; \n"];
    [javaString appendString:@"import com.ambassador.ambassadorsdk.ConversionParameters; \n"];
    [javaString appendString:@"import com.ambassador.ambassadorsdk.AmbassadorSDK; \n\n"];
    [javaString appendString:@"public class MyApplication extends Application { \n\n"];
    [javaString appendString:@"    @Override \n"];
    [javaString appendString:@"    public void onCreate() { \n"];
    [javaString appendString:@"        super.onCreate(); \n"];
    [javaString appendString:runWithKeysString];
    [javaString appendString:insert];
    [javaString appendString:@"    } \n"];
    [javaString appendString:@"}"];
    
    return javaString;
}

+ (NSString *)readMeForRequest:(NSString *)requestName {
    // Create versionStrings
    NSString *iosVersionString = [NSString stringWithFormat:@"iOS AmbassadorSDK v%@ \n", [ValuesHandler iosVersionNumber]];
    NSString *androidVersionString = [NSString stringWithFormat:@"Android AmbassadorSDK v%@ \n", [ValuesHandler androidVersionNumber]];
    NSString *iosRequestTypeString = [NSString stringWithFormat:@"Checkout the AppDelegate.m or AppDelegate.swift files for examples of this %@ request. \n\n", requestName];
    NSString *androidRequestTypeString = [NSString stringWithFormat:@"Checkout the MyApplication.java file for an example of this %@ request.", requestName];
    
    // Builds README file
    NSMutableString *readmeSting = [[NSMutableString alloc] init];
    [readmeSting appendString:iosVersionString];
    [readmeSting appendString:@"Take a look at the iOS docs for an in-depth explanation on adding and integrating the SDK: \n"];
    [readmeSting appendString:@"https://docs.getambassador.com/v2.0.0/page/ios-sdk \n"];
    [readmeSting appendString:iosRequestTypeString];
    [readmeSting appendString:androidVersionString];
    [readmeSting appendString:@"Take a look at the android docs for an in-depth explanation on adding and integrating the SDK: \n"];
    [readmeSting appendString:@"https://docs.getambassador.com/v2.0.0/page/android-sdk \n"];
    [readmeSting appendString:androidRequestTypeString];
    
    return readmeSting;
}

+ (NSString *)objcViewControllerWithInsert:(NSString *)insert {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"    [AmbassadorSDK runWithUniversalToken:\"%@\" universalID:\"%@\"]; \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    // Builds Objective-C ViewController
    NSMutableString *objcString = [[NSMutableString alloc] initWithString:@"#import \"ViewControllerTest.h\"\n"];
    [objcString appendString:@"#import <Ambassador/Ambassador.h>\n\n"];
    [objcString appendString:@"@interface ViewControllerTest ()\n\n"];
    [objcString appendString:@"@end\n\n"];
    [objcString appendString:@"@implementation ViewControllerTest\n\n"];
    [objcString appendString:@"- (void)viewDidAppear:(BOOL)animated {\n"];
    [objcString appendString:runWithKeysString];
    [objcString appendString:insert];
    [objcString appendString:@"}\n\n"];
    [objcString appendString:@"@end"];
    
    return objcString;
}

+ (NSString *)swiftViewControllerWithInsert:(NSString *)insert {
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithUniversalToken(\"%@\", universalID: \"%@\") \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    NSMutableString *swiftString = [[NSMutableString alloc] initWithString:@"import UIKit\n\n"];
    [swiftString appendString:@"class ViewController: UIViewController {\n\n"];
    [swiftString appendString:    @"override func viewDidAppear(animated: Bool) {\n"];
    [swiftString appendString:runWithKeysString];
    [swiftString appendString:insert];
    [swiftString appendString:@"    }\n\n"];
    [swiftString appendString:@"}"];
    
    return swiftString;
}

+ (NSString *)javaActivityWithInsert:(NSString *)insert {
    // Gets dynamic strings from user's tokens and email input
    NSString *runWithKeysString = [NSString stringWithFormat:@"        AmbassadorSDK.runWithKeys(this, \"SDKToken %@\", \"%@\"); \n", [DefaultsHandler getSDKToken], [DefaultsHandler getUniversalID]];
    
    // Build java string
    NSMutableString *javaString = [[NSMutableString alloc] initWithString:@"package com.example.example;\n\n"];
    [javaString appendString:@"import android.app.Activity;\n"];
    [javaString appendString:@"import android.os.Bundle;\n"];
    [javaString appendString:@"import com.ambassador.ambassadorsdk.AmbassadorSDK;\n\n"];
    [javaString appendString:@"public class MyActivity extends Activity {\n\n"];
    [javaString appendString:@"    @Override\n"];
    [javaString appendString:@"    public void onCreate(Bundle savedInstanceState) {\n"];
    [javaString appendString:@"        super.onCreate(savedInstanceState);\n"];
    [javaString appendString:runWithKeysString];
    [javaString appendString:insert];
    [javaString appendString:@"    }\n\n"];
    [javaString appendString:@"}"];
    
    return javaString;
}

+ (NSString *)readmeForRAF {
    // Create versionStrings
    NSString *iosVersionString = [NSString stringWithFormat:@"iOS AmbassadorSDK v%@ \n", [ValuesHandler iosVersionNumber]];
    NSString *androidVersionString = [NSString stringWithFormat:@"Android AmbassadorSDK v%@ \n", [ValuesHandler androidVersionNumber]];
    
    // Builds README file
    NSMutableString *readmeSting = [[NSMutableString alloc] init];
    [readmeSting appendString:iosVersionString];
    [readmeSting appendString:@"Take a look at the iOS docs for an in-depth explanation on adding and integrating the SDK: \n"];
    [readmeSting appendString:@"https://docs.getambassador.com/v2.0.0/page/ios-sdk \n"];
    [readmeSting appendString:@"Check out the ViewControllerTest.m or ViewControllerTest.swift files for examples of this integration."];
    [readmeSting appendString:@"Add the image to your app's image assets folder and add the .plist file to your project.\n\n"];
    [readmeSting appendString:androidVersionString];
    [readmeSting appendString:@"Take a look at the android docs for an in-depth explanation on adding and integrating the SDK: \n"];
    [readmeSting appendString:@"https://docs.getambassador.com/v2.0.0/page/android-sdk \n"];
    [readmeSting appendString:@"Check out the MyActivity.java file for an example of this integration."];
    [readmeSting appendString:@"Place the image and ambassador-raf.xml files into the root of your application's assets folder."];
    
    return readmeSting;
}

@end