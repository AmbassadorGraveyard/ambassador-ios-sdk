# ambassador-ios-sdk

## Documentation

### Setup

* Download the framework file
* Copy the framework file into your Xcode project
* Opt to copy files if necessary when prompted
* Navigate to ```AppDelegate.m``` and locate ```application:application didFinishLaunchingWithOptions:```
* If your don't want to trigger a conversion on application launch add:
  ```objective-c
  [Ambassador runWithKey:@"abc123" convertingOnLaunch:nil];
  ```
  **OR**

  Create a dictionary with conversion parameters and pass that in:
  ```objective-c
  [Ambassador runWithKey:@"abc123" convertingOnLaunch:@{/*your_dictionary*/}];
  ```
 
