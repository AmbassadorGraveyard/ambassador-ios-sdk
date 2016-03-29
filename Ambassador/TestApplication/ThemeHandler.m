//
//  ThemeHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/22/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "ThemeHandler.h"
#import "DefaultsHandler.h"

@implementation ThemeHandler


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
    NSData *pngData = UIImagePNGRepresentation(image);
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageSavePath]];
    [pngData writeToFile:filePath atomically:NO];
}

+ (void)writeToDocumentsPathWithThemeName:(NSString*)name dictionary:(NSMutableDictionary*)writeDict {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    [writeDict writeToFile:filePath atomically:NO];
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

@end
