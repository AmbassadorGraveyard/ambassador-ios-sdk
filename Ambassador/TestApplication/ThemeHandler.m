//
//  ThemeHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ThemeHandler.h"
#import "DefaultsHandler.h"
#import <zipzap/ZipZap.h>
#import "FileWriter.h"

@implementation ThemeHandler

NSString * rafZipConstant = @"ambassador-raf.zip";


#pragma mark - Save Functions

+ (void)saveTheme:(RAFItem*)rafTheme {
    // Gets current array of RAFItems(themes) and add the new RAFitem
    NSMutableArray *currentThemeArray = [DefaultsHandler getThemeArray];
    
    /* Run through theme array to see if we should
     add a new RAF item or override existing RAF item
     based on the date created */
    RAFItem *matchingItem = nil;
    for (RAFItem *item in currentThemeArray) {
        if ([item.dateCreated isEqual:rafTheme.dateCreated]) {
            matchingItem = item;
        }
    }
    
    // Perform override or new save
    if (matchingItem) {
        NSUInteger matchingIndex = [currentThemeArray indexOfObject:matchingItem];
        [currentThemeArray replaceObjectAtIndex:matchingIndex withObject:rafTheme];
    } else {
        [currentThemeArray addObject:rafTheme];
    }
    
    // Saves the updated Array of RAFItems to user defaults
    [DefaultsHandler setThemeArray:currentThemeArray];
    
    // Creats a copy of genericTheme to alter and save as new plist
    NSMutableDictionary *dictionary = rafTheme.plistDict;
    
    /* New plists created from within the TestApp are
     appended with AMBTESTAPP so that the SDK knows
     to grab them from the Documents folder. The
     Documents folder is the recommended area for writing to files*/
    [ThemeHandler writeToDocumentsPathWithThemeName:rafTheme.plistFullName dictionary:dictionary];
}

+ (void)saveImage:(UIImage*)image forTheme:(RAFItem*)theme {
    NSString *imageSavePath = [theme.plistFullName stringByAppendingString:@"Image"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSData *jpgData = UIImageJPEGRepresentation(image, 1.0);
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageSavePath]];
    [jpgData writeToFile:filePath atomically:NO];
}

+ (void)writeToDocumentsPathWithThemeName:(NSString*)name dictionary:(NSMutableDictionary*)writeDict {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    [writeDict writeToFile:filePath atomically:NO];
}

+ (BOOL)duplicateRAFName:(NSString*)name {
    NSMutableArray *currentThemeArray = [DefaultsHandler getThemeArray];
    
    for (RAFItem *item in currentThemeArray) {
        if ([name isEqualToString:item.rafName]) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)packageZipForRAF:(RAFItem *)raf {
    // Creates a new directiry in the documents folder
    NSString *saveFolder = [[FileWriter documentsPath] stringByAppendingPathComponent:raf.plistFullName];
    NSString *filePath = [saveFolder stringByAppendingPathComponent:rafZipConstant];
    
    // Creates an array of files for the zip file
    NSMutableArray *entriesArray = [[NSMutableArray alloc] initWithObjects:[self getObjcFile:raf], [self getSwiftFile:raf], [self getPlist:raf],
                                    [self getJavaFile:raf], [self getJavaXMLFile:raf], nil];
    
    // Checks if there is an image tied to the RAF, and includes it if so
    if ([self getThemeImage:raf]) { [entriesArray addObject:[self getThemeImage:raf]]; }
    
    // Creates a new zip file containing all different files
    ZZArchive* newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:@{ZZOpenOptionsCreateIfMissingKey : @YES} error:nil];
    [newArchive updateEntries:entriesArray error:nil];
}

#pragma mark - Delete Functions

+ (void)deleteRafItem:(RAFItem*)rafItem {
    // Get current array of themes
    NSMutableArray *currentThemeArray = [DefaultsHandler getThemeArray];
    
    /* Need to loop though items and check names
     rather than removing object directly because
     references are different since the array was
     encoded and decoded */
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    for (RAFItem *item in currentThemeArray) {
        if ([item.rafName isEqualToString:rafItem.rafName]) {
            [removeArray addObject:item];
        }
    }
    
    [currentThemeArray removeObjectsInArray:removeArray];
    
    // Re-save the array once the rafItem has been removed
    [DefaultsHandler setThemeArray:currentThemeArray];
    
    // Remove the plist from Documents and image if exists
    [ThemeHandler removeFileFromPathWithThemeName:rafItem.plistFullName];
    [ThemeHandler removeImageForTheme:rafItem];
}

+ (void)removeImageForTheme:(RAFItem*)theme {
    if (theme.imageFilePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *fileMngError;
        BOOL removed = [fileManager removeItemAtPath:theme.imageFilePath error:&fileMngError];
        
        if (removed) {
            NSLog(@"Image removed successfully!");
        } else {
            NSLog(@"Failed to removed image - %@", fileMngError);
        }
    }
}

+ (void)removeFileFromPathWithThemeName:(NSString*)name {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    
    // Use the file manager to remove the file at path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileMngError;
    BOOL removed = [fileManager removeItemAtPath:filePath error:&fileMngError];
    
    if (removed) {
        NSLog(@"File removed successfully!");
    } else {
        NSLog(@"Failed to removed file - %@", fileMngError);
    }
}


#pragma mark - Getter Functions

+ (NSMutableDictionary *)getGenericTheme {
    // Creates and returns a copy of the GenericTheme
    NSString *genericThemePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ambassador.bundle"];
    NSMutableDictionary *genericThemeDict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithPath:genericThemePath] pathForResource:@"GenericTheme" ofType:@"plist"]];
    
    return genericThemeDict;
}

+ (NSMutableDictionary *)dictionaryFromPlist:(RAFItem*)item {
    NSString *rafPath = [ThemeHandler getDocumentsPathWithName:item.plistFullName];
    NSMutableDictionary *plistDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:rafPath];
    
    return plistDictionary;
}

+ (NSString *)getDocumentsPathWithName:(NSString*)themeName {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Gets file path for plist
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", themeName]];
    return filePath;
}

+ (UIImage *)getImageForRAF:(RAFItem*)item {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:item.imageFilePath];
    return [UIImage imageWithContentsOfFile:filePath];
}

+ (NSURL *)getZipForRAF:(RAFItem *)raf {
    NSString *retrieveFolder = [[FileWriter documentsPath] stringByAppendingPathComponent:raf.plistFullName];
    NSString *filePath = [retrieveFolder stringByAppendingPathComponent:rafZipConstant];
    
    
    // Creates a file based on the path using a url
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return fileURL != nil ? fileURL : nil;
}


#pragma mark - Zip File Functions

+ (ZZArchiveEntry *)getObjcFile:(RAFItem *)rafItem {
    NSString *objcLine = [NSString stringWithFormat:@"    [AmbassadorSDK presentRAFForCampaign:@\"%@\" FromViewController:self withThemePlist:@\"%@\"];\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *objcFile = [FileWriter objcViewControllerWithInsert:objcLine];
    
    ZZArchiveEntry *objcEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ViewControllerTest.m" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [objcFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return objcEntry;
}

+ (ZZArchiveEntry *)getSwiftFile:(RAFItem *)rafItem {
    NSString *swiftLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAFForCampaign(\"%@\", fromViewController: self, withThemePlist: \"%@\")\n", rafItem.campaign.campID, rafItem.rafName];
    NSString *swiftFile = [FileWriter swiftViewControllerWithInsert:swiftLine];
    
    ZZArchiveEntry *swiftEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ViewControllerTest.swift" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [swiftFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return swiftEntry;
}

+ (ZZArchiveEntry *)getPlist:(RAFItem *)rafItem {
    NSString *plistPath = [ThemeHandler getDocumentsPathWithName:rafItem.plistFullName];
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", rafItem.rafName];
    
    ZZArchiveEntry *plistEntry = [ZZArchiveEntry archiveEntryWithFileName:plistName compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [NSData dataWithContentsOfFile:plistPath];
    }];
    
    return plistEntry;
}

+ (ZZArchiveEntry *)getJavaFile:(RAFItem *)rafItem {
    NSString *javaLine = [NSString stringWithFormat:@"        AmbassadorSDK.presentRAF(this, \"%@\", \"ambassador-raf.xml\");\n", rafItem.campaign.campID];
    NSString *javaFile = [FileWriter javaActivityWithInsert:javaLine];
    
    ZZArchiveEntry *javaEntry = [ZZArchiveEntry archiveEntryWithFileName:@"MyApplication.java" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return [javaFile dataUsingEncoding:NSUTF8StringEncoding];
    }];
    
    return javaEntry;
}

+ (ZZArchiveEntry *)getJavaXMLFile:(RAFItem *)rafItem {
    // If the RAF was created before android export was included, we need to generate the xml here
    if (!rafItem.xmlFileData) { [rafItem generateXMLFromPlist:rafItem.plistDict]; }
    
    ZZArchiveEntry *xmlEntry = [ZZArchiveEntry archiveEntryWithFileName:@"ambassador-raf.xml" compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return rafItem.xmlFileData;
    }];
    
    return xmlEntry;
}

+ (ZZArchiveEntry *)getThemeImage:(RAFItem *)rafItem {
    UIImage *rafImage = [ThemeHandler getImageForRAF:rafItem];
    NSData *imageAttachmentData =  UIImagePNGRepresentation(rafImage);
    NSString *imageName = [NSString stringWithFormat:@"%@.png", rafItem.imageFilePath];
    
    if (!imageAttachmentData) { return nil; }
    
    ZZArchiveEntry *imageEntry = [ZZArchiveEntry archiveEntryWithFileName:imageName compress:YES dataBlock:^NSData * _Nullable(NSError * _Nullable __autoreleasing * _Nullable error) {
        return imageAttachmentData;
    }];
    
    return imageEntry;
}

@end
