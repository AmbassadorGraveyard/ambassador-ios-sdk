//
//  AppDelegate.h
//  SDKTestApp
//
//  Created by Matthew Majewski on 4/26/18.
//  Copyright © 2018 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

