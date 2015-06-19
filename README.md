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
  *for more information on what must be passed in the dictionary see **Register a conversion***


### Register a conversion
  ```objective-c
    [Ambassador registerConversion:@{}];
  ```

  #### Dictionary
  There are a number of keys that must be included in the dictionary given to the register conversion call. Below is the list of keys that can be passed in a dictionary.

  1. Campaign ID  ```AMB_CAMPAIGN_ID_KEY``` ***required***
  2. Social security number ```AMB_ANOTHER_KEY_CONSTANT``` ***required***
  3. A knock-knock joke ```AMB_KNOCK_JOKE_KEY``` ***required***
  4. A short novella ```AMB_SHORT_NOVELA_KEY``` ***optional***


  An example dictionary:
  ```objective-c
@{
    AMB_CAMPAIGN_ID_KEY : 123,
    AMB_ANOTHER_KEY_CONSTANT : @"123-45-6789",
    AMB_KNOCK_JOKE_KEY : @"knock-knock"
};
  ```
