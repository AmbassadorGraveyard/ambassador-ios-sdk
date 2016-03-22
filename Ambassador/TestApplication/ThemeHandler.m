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

- (NSMutableDictionary *)getGenericTheme {
    // Creates and returns a copy of the GenericTheme
    NSString *genericThemePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Ambassador.bundle"];
    NSMutableDictionary *genericThemeDict = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithPath:genericThemePath] pathForResource:@"GenericTheme" ofType:@"plist"]];
    
    return genericThemeDict;
}

- (void)saveNewTheme:(RAFItem*)rafTheme {
    // Gets current array of RAFItems(themes) and add the new RAFitem
    NSMutableArray *currentThemeArray = [[NSMutableArray alloc] initWithArray:[DefaultsHandler getThemeArray]];
    [currentThemeArray addObject:rafTheme];
    
    // Saves the updated Array of RAFItems to user defaults
    NSArray *saveArray = [NSArray arrayWithArray:currentThemeArray];
    [DefaultsHandler setThemeArray:saveArray];
    
    // Creats a copy of genericTheme to alter and save as new plist
    NSMutableDictionary *dictionary = [self getGenericTheme];
    
    /* New plists created from within the TestApp are
    appended with AMBTESTAPP so that the SDK knows
    to grab them from the Documents folder. The
    Documents folder is the recommended area for writing to files*/
    [self writeToDocumentsPathWithThemeName:rafTheme.plistFullName dictionary:dictionary];
}

- (void)writeToDocumentsPathWithThemeName:(NSString*)name dictionary:(NSMutableDictionary*)writeDict {
    // Gets path for Documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creates and writes to a new or existing file path with the path name
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    [writeDict writeToFile:filePath atomically:NO];
}

@end
