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

+ (NSString *)readMeForRequest:(READMETypes)readmeType containsImage:(NSString*)imageName {
    // Decides which values to use based on the readmeType
    NSString *requestName = [FileWriter stringFromReadmeType:readmeType];
    BOOL isRAF = readmeType == ReadmeTypeRAF;
    
    NSString *iosFileName = isRAF ? @"ViewControllerTest.m or ViewControllerTest.swift and the .plist" : @"AppDelegate.m or AppDelegate.swift";
    NSString *androidFileName = isRAF ? @"MyActivity.java and ambassador-raf.xml files" : @"MyApplication.java file";
    NSString *androidEndChar = imageName != nil && ![imageName isEqualToString:@""] ? @"," : @".";
    
    // Creates formatted strings
    NSString *greetingString = [NSString stringWithFormat:@"Hey! I've attached examples showing how to %@ in our mobile app with the Ambassador SDK.\n\n", requestName];
    NSString *iosVersionString = [NSString stringWithFormat:@"iOS (v%@): %@,\n", [ValuesHandler iosVersionNumber], iosFileName];
    NSString *androidVersionString = [NSString stringWithFormat:@"Android (v%@): %@%@\n", [ValuesHandler androidVersionNumber], androidFileName, androidEndChar];
    NSString *imageString = imageName != nil && ![imageName isEqualToString:@""] ? [NSString stringWithFormat:@"and %@, a custom image used in the theme configuration. \n\n", imageName] : @"\n";
    
    // Builds README file
    NSMutableString *readmeString = [[NSMutableString alloc] init];
    [readmeString appendString:greetingString];
    [readmeString appendString: @"The attachment includes examples for\n"];
    [readmeString appendString:iosVersionString];
    [readmeString appendString:androidVersionString];
    [readmeString appendString:imageString];
    [readmeString appendString:@"For in-depth explanations on adding and integrating the SDKs check out the following\n"];
    [readmeString appendString:@"iOS -> https://docs.getambassador.com/v2.0.0/page/ios-sdk\n"];
    [readmeString appendString:@"Android -> https://docs.getambassador.com/v2.0.0/page/android-sdk\n\n"];
    [readmeString appendString:@"Let me know if you have any questions!\n\n\n\n\n"]; // 5 new lines so that the last line doesn't show up in gmail as a signature
    
    return readmeString;
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

+ (NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

+ (NSString *)stringFromReadmeType:(READMETypes)type {
    switch (type) {
        case ReadmeTypeIdentify: return @"identify users";
        case ReadmeTypeConversion: return @"set up a conversion";
        case ReadmeTypeRAF: return @"set up a refer-a-friend view";
        default: break;
    }
}

@end
