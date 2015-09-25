# Ambassador iOS SDK

## Getting Started
Install Git hooks:
```
ln -s ../../git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
```

## Documentation
## Installing the SDK
Follow the steps to install the Ambassador SDK in your Objective-c or Swift project.
* Download the framework zip file, unzip it, and drag Ambassador.framework and Ambassador.bundle into your project, as shown below, beneath the project file (the zip file is attached at the bottom of this article).

  <img src="screenShots/Install_pt1.png" width="300" />

* Elect to copy the framework files into your project

  <img src="screenShots/Install_pt2.png" width="600" />

* Link to the following libraries:
  * libsqlite3
  * libicucore

  <img src="screenShots/Install_pt3.png" width="600" />

* Add an `-ObjC` flag under `Build Settings > Other Linker Flags`

<img src="screenShots/Install_pt4.png" width="600" />

### Adding a bridging header (Swift projects)
The SDK is written in Objective-c. In addition to the previous steps, installing the SDK into a Swift project requires a bridging header. If your project doesn't already have a bridging header, you can add one easily. If you already have a bridging header due to another library or framework, you can go to [Configuring a Bridging header (Swift Projects)](#config-bridge)

* Add a new file to your project.

  <img src="screenShots/Install_pt6.png" width="600" />

* Select the Objective-C file type.

  <img src="screenShots/Install_pt7.png" width="600" />

* This is essentially a dummy file, and you can name it anything.

  <img src="screenShots/Install_pt8.png" width="600" />

* A Prompt will appear asking if you want to configure a bridging header. Select yes.

  <img src="screenShots/Install_pt9.png" width="600" />

* This will create both the dummy Objective-C file and a bridging header sharing the name of your project.

  <img src="screenShots/Install_pt10.png" width="300" />

* At this point, you can delete the dummy Objective-C file. It is no longer needed.

  <img src="screenShots/Install_pt11.png" width="450" />

### <a name="config-bridge"></a>Configuring a Bridging header (Swift projects)

In the bridging header, add an import statement for the Ambassador SDK.

```objective-c
#import <Ambassador/Ambassador.h>
```

## Initializing Ambassador

### Step 1
If you're using Objective-C, import the Ambassador framework in your `AppDelegate.m`.

  **Objective-c**
  ```objective-c
  #import <Ambassador/Ambassador.h>
  ```

### Step 2
You run Ambassador inside `application:didFinishLaunchingWithOptions:`
and have the option to convert on install. This will register a conversion
the first time the app is launched. More on conversions and setting their
parameters in [Conversions](#conversions). Your Universal Token and Universal ID will be provided to you by Ambassador.

**Objective-c**
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.

  // If you don't want to register a conversion during the first launch of your
  // application, then pass nil for the convertOnInstall parameter
  [AmbassadorSDK runWithUniversalToken:<your_universal_token> universalID:<your_universal_id>];

  //--OR--

  // If you would like to register a conversion for one of your campaigns,
  // create a conversion object to pass for the convertOnInstall parameter
  AMBConversionParameters *parameters = [[AMBConversionParameters alloc] init];
  // ... set parameters' properties (more on this in the "Conversions" section)
  [AmbassadorSDK runWithUniversalToken:<your_universal_token> universalID:<your_universal_id> convertOnInstall:parameters completion:^(NSError *error) {
      if (error) {
         NSLog(@"Error %@", error);
     }
     else {
         NSLog(@"All conversion parameters are set properly");
     }
 }];

  return YES;
}
```

**Swift**
```objective-c
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
{
    // Override point for customization after application launch.

    // If you don't want to register a conversion during the first launch of your
    // application, then pass nil for the convertOnInstall parameter
    AmbassadorSDK.runWithUniversalToken(<your_universal_token>, universalID:<your_universal_id>)

    //--OR--

    // If you would like to register a conversion for one of your campaigns,
    // create a conversion object to pass for the convertOnInstall parameter
    var parameters = AMBConversionParameters()
    // ... set parameters' properties (more on this in the "Conversions" section)
    AmbassadorSDK.runWithUniversalToken(<your_universal_token>, universalID:<your_universal_id>, convertOnInstall:parameters) { (error) -> Void in
        if ((error) != nil) {
            println("Error \(error)")
        } else {
            println("All conversion parameters are set properly")
        }
    }

    return true
}
```

## Identifying a User
In order to track referrals and provide users with custom share links,
Ambassador only needs the email address of the user. The call to identify
the user should be done early in the app to make sure all Ambassador services
 can be provided as soon as possible. We recommend putting it on a login screen
 or after the initial call to run Ambassador if you have the user's email stored.

 **Objective-c**
```objective-c
[AmbassadorSDK identifyWithEmail:@"user@example.com"];
```

**Swift**

```objective-c
AmbassadorSDK.identifyWithEmail("user@example.com")
```

## Conversions
Conversions can be triggered from anywhere. Common places could be a view controller's ```viewDidLoad``` or on a button event.

**Objective-c**
```objective-c
// STEP ONE: Create a conversion parameters object
AMBConversionParameters *conversion = [[AMBConversionParameters alloc] init];

// STEP TWO: Set the required properties
conversion.mbsy_revenue = @10; // NSNumber
conversion.mbsy_campaign = @101; // NSNumber
conversion.mbsy_email = @"user@example.com"; // NSString

// STEP THREE: Set any optional properties
conversion.mbsy_add_to_group_id = @"123"; // NSString
conversion.mbsy_first_name = @"John"; // NSString
conversion.mbsy_last_name = @"Doe"; // NSString
conversion.mbsy_email_new_ambassador = @NO; // BOOL (Deafaults to @NO)
conversion.mbsy_uid = @"mbsy_uid"; // NSString
conversion.mbsy_custom1 = @"custom1"; // NSString
conversion.mbsy_custom2 = @"custom2"; // NSString
conversion.mbsy_custom3 = @"custom3"; // NSString
conversion.mbsy_auto_create = @YES; // BOOL (Defaults to @YES)
conversion.mbsy_deactivate_new_ambassador = @NO; // BOOL (Defaults to @NO)
conversion.mbsy_transaction_uid = @"trans_uid"; // NSString
conversion.mbsy_event_data1 = @"eventdata1"; // NSString
conversion.mbsy_event_data2 = @"eventdata2"; // NSString
conversion.mbsy_event_data3 = @"eventdata3"; // NSString
conversion.mbsy_is_approved = @YES; // BOOL (Defaults to @YES)

// STEP FOUR: Register the conversion with the parameter object
[AmbassadorSDK registerConversion:conversion completion:^(NSError *error) {
    if (error) {
        NSLog(@"Error %@", error);
    }
    else {
        NSLog(@"All conversion parameters are set properly");
    }
}];
```

**Swift**
```objective-c
// STEP ONE: Create a conversion parameters object
let parameters = AMBConversionParameters()

// STEP TWO: Set the required properties
parameters.mbsy_revenue = 10 // NSNumber
parameters.mbsy_campaign = 101 // NSNumber
parameters.mbsy_email = "user@example.com" // NSString

// STEP THREE: Set any optional properties
parameters.mbsy_add_to_group_id = "123" // NSString
parameters.mbsy_first_name = "John" // NSString
parameters.mbsy_last_name = "Doe" // NSString
parameters.mbsy_email_new_ambassador = false // BOOL (Deafaults to false)
parameters.mbsy_uid = "mbsy_uid" // NSString
parameters.mbsy_custom1 = "custom1" // NSString
parameters.mbsy_custom2 = "custom2" // NSString
parameters.mbsy_custom3 = "custom3" // NSString
parameters.mbsy_auto_create = true // BOOL (Defaults to true)
parameters.mbsy_deactivate_new_ambassador = false // BOOL (Defaults to false)
parameters.mbsy_transaction_uid = "trans_uid" // NSString
parameters.mbsy_event_data1 = "eventdata1" // NSString
parameters.mbsy_event_data2 = "eventdata2" // NSString
parameters.mbsy_event_data3 = "eventdata3" // NSString
parameters.mbsy_is_approved = true // BOOL (Defaults to true)

// STEP FOUR: Register the conversion with the parameter object
AmbassadorSDK.registerConversion(parameters)  { (error) -> Void in
  if ((error) != nil) {
      println("Error \(error)")
  } else {
       println("All conversion parameters are set properly")
   }
}
```

## Presenting the 'Refer A Friend' Screen (RAF)
### Service Selector Preferences
The RAF screen provides a UI component that allows users to share with their contacts and become part of your referral program.
To allow customization, there is an `AmbassadorTheme.plist` where you can set many editable properties of the RAF, including colors, messages, and fonts.

  <img src="screenShots/AmbassadorThemeSelection.png" width="250" />

If you leave any property unset, the RAF will use the default values shown below.
Any blank or incorrect values inserted into the `AmbassadorTheme.plist` will default to:
* Colors - White
* Fonts - **System Font** of size **14**
* Messages - **"NO PLIST VALUE FOUND"**

The `AmbassadorTheme.plist` will come with preconfigured values looking like this:

  <img src="screenShots/themePlist.png" width="1000" />

This is what the default theme will look like with the preconfigured values in the `AmbassadorTheme.plist`.

  <img src="screenShots/rafDemoImg.jpg" width="250" />   <img src="screenShots/contactShare.jpg" width="250"/>

After some minor configurations, the RAF can easily be changed to look like this:

  <img src="screenShots/changedRAFScreen.png" width="250" />   <img src="screenShots/changedContactScreen.png" width="250"/>

**NOTES FOR CUSTOM THEMES**

* **Colors must be entered as Hex Code values**
* **Make sure when adding custom colors to the plist that you include a `#` in front of the Hex Code or it may result with incorrect colors**
* **Fonts are typically entered as `<FontName>, <FontSize>`.  Ex: `Helvetica, 12`**
* **If you leave out the font size, it will be defaulted to size 14**

### Presenting the RAF
**Objective-c**
```objective-c
// Present the RAF Modal View
[AmbassadorSDK presentRAFForCampaign:@"877" FromViewController:self];
```

**Swift**
```objective-c
// Present the RAF Modal View
AmbassadorSDK.presentRAFForCampaign("877", fromViewController: self)
```

**NOTES**

* **It is important that the view controller being passed is in the view hierarchy before the call is made. (If the RAF is going to be presented upon the launch of the view controller, but the method call in ```viewDidApprear:``` instead of ```viewDidLoad```)**

* **Identify should also be called before any calls to present a RAF. Identify will need to generate/update the short urls, and therefore should not be placed immediately before any RAF presentation calls.  This will allow the share urls to be generated for your user. If identify is not called before, or a campaign ID that does not exist is passed, a warning will be logged to let you know**
