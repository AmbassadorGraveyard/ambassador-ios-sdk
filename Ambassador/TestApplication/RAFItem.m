//
//  RAFItem.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "RAFItem.h"
#import "AMBValues.h"

@implementation RAFItem

#pragma mark - LifeCycle

// Decodes properties that were previously recorded
- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.rafName = [decoder decodeObjectForKey:@"rafName"];
        self.plistFullName = [decoder decodeObjectForKey:@"plistFullName"];
        self.dateCreated = [decoder decodeObjectForKey:@"dateCreated"];
        self.plistDict = [decoder decodeObjectForKey:@"plistDict"];
        self.campaign = [decoder decodeObjectForKey:@"campaign"];
        self.imageFilePath = [decoder decodeObjectForKey:@"imageFilePath"];
        self.xmlFileData = [decoder decodeObjectForKey:@"xmlFileData"];
    }
    
    return self;
}

// Encodes RAFItem in order to store to user defaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.rafName forKey:@"rafName"];
    [encoder encodeObject:self.plistFullName forKey:@"plistFullName"];
    [encoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [encoder encodeObject:self.plistDict forKey:@"plistDict"];
    [encoder encodeObject:self.campaign forKey:@"campaign"];
    [encoder encodeObject:self.imageFilePath forKey:@"imageFilePath"];
    [encoder encodeObject:self.xmlFileData forKey:@"xmlFileData"];
}

- (instancetype)initWithName:(NSString*)name plistDict:(NSMutableDictionary*)dict {
    self = [super init];
    self.rafName = name;
    self.plistFullName = [NSString stringWithFormat:@"%@%@", TEST_APP_CONTSTANT, name];
    self.dateCreated = [NSDate date];
    self.plistDict = dict;
    [self generateXMLFromPlist:dict];
    
    return self;
}


#pragma mark - Helper Functions

- (void)generateXMLFromPlist:(NSMutableDictionary *)plist {
    // Creates string for image
    NSString *imageString = ![plist[@"RAFLogo"] isEqualToString:@""] ? [plist[@"RAFLogo"] stringByAppendingString:@".png"] : @"";
    
    // Creates a string based on the social channel array for android
    NSString *channelString = plist[@"Channels"];
    NSArray *socialArray = [channelString componentsSeparatedByString:@","];
    NSMutableString *androidSocialArrayString = [[NSMutableString alloc] init];
    
    for (NSString *channel in socialArray) {
        NSString *uppercaseString = [channel uppercaseString];
        [androidSocialArrayString appendString:[NSString stringWithFormat:@"        <item>%@</item>\n", uppercaseString]];
    }
    
    
    // Writes the xml file data
    NSMutableString *xmlFileString = [[NSMutableString alloc] initWithString:@"<resources>\n"];
    [xmlFileString appendString:@"    <string name=\"RAFdefaultShareMessage\">Check out this company!</string>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <string name=\"RAFtitleText\">%@</string>\n", plist[@"RAFWelcomeTextMessage"]]];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <string name=\"RAFtoolbarTitle\">%@</string>\n", plist[@"NavBarTextMessage"]]];
    [xmlFileString appendString:@"    <string name=\"RAFLogoPosition\">1</string>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <string name=\"RAFLogo\">%@</string>\n", imageString]];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <string name=\"RAFdescriptionText\">%@</string>\n", plist[@"RAFDescriptionTextMessage"]]];
    [xmlFileString appendString:@"    <color name=\"homeBackground\">#FFFFFF</color>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"homeWelcomeTitle\">%@</color>\n", plist[@"RAFWelcomeTextColor"]]];
    [xmlFileString appendString:@"    <dimen name=\"homeWelcomeTitle\">22sp</dimen>\n"];
    [xmlFileString appendString:@"    <string name=\"homeWelcomeTitle\">sans-serif</string>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"homeWelcomeDesc\">%@</color>\n", plist[@"RAFDescriptionTextColor"]]];
    [xmlFileString appendString:@"    <dimen name=\"homeWelcomeDesc\">18sp</dimen>\n"];
    [xmlFileString appendString:@"    <string name=\"homeWelcomeDesc\">sans-serif</string>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"homeToolBar\">%@</color>\n", plist[@"NavBarColor"]]];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"homeToolBarText\">%@</color>\n", plist[@"NavBarTextColor"]]];
    [xmlFileString appendString:@"    <string name=\"homeToolBarText\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <color name=\"homeToolBarArrow\">#FFFFFF</color>\n"];
    [xmlFileString appendString:@"    <color name=\"homeShareTextBar\">#EBEBEB</color>\n"];
    [xmlFileString appendString:@"    <color name=\"homeShareText\">#B3B3B3</color>\n"];
    [xmlFileString appendString:@"    <dimen name=\"homeShareText\">12sp</dimen>\n"];
    [xmlFileString appendString:@"    <string name=\"homeShareText\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <string name=\"socialGridText\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <dimen name=\"socialOptionCornerRadius\">0dp</dimen>\n"];
    [xmlFileString appendString:@"    <array name=\"channels\">\n"];
    [xmlFileString appendString:androidSocialArrayString];
    [xmlFileString appendString:@"    </array>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsListViewBackground\">#FFFFFF</color>\n"];
    [xmlFileString appendString:@"    <dimen name=\"contactsListName\">15sp</dimen>\n"];
    [xmlFileString appendString:@"    <string name=\"contactsListName\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <dimen name=\"contactsListValue\">12sp</dimen>\n"];
    [xmlFileString appendString:@"    <string name=\"contactsListValue\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsSendBackground\">#FFFFFF</color>\n"];
    [xmlFileString appendString:@"    <string name=\"contactSendMessageText\">sans-serif</string>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsToolBar\">#3C97D3</color>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsToolBarText\">#FFFFFF</color>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsToolBarArrow\">#FFFFFF</color>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"contactsSendButton\">%@</color>\n", plist[@"ContactSendButtonBackgroundColor"]]];
    [xmlFileString appendString:@"    <color name=\"contactsSendButtonText\">#FFFFFF</color>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsDoneButtonText\">#3C97D3</color>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsSearchBar\">#000000</color>\n"];
    [xmlFileString appendString:@"    <color name=\"contactsSearchIcon\">#FFFFFF</color>\n"];
    [xmlFileString appendString:[NSString stringWithFormat:@"    <color name=\"contactNoPhotoAvailableBackground\">%@</color>\n", plist[@"ContactSendButtonBackgroundColor"]]];
    [xmlFileString appendString:[NSString stringWithFormat:@"</resources>"]];
    
    self.xmlFileData = [xmlFileString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
