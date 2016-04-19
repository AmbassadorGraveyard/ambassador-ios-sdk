//
//  UIActivityViewController+ZipShare.m
//  Ambassador
//
//  Created by Jake Dunahee on 4/19/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "UIActivityViewController+ZipShare.h"

@implementation UIActivityViewController (ZipShare)

+ (void)shareZip:(NSURL *)zip withMessage:(NSString *)message subject:(NSString *)subject forPresenter:(UIViewController *)presenter {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[message, zip] applicationActivities:nil];
    [controller setValue:subject forKey:@"subject"];
    
    // Filter out the sharing methods we're not interested in....
    controller.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    
    // Now display the sharing view controller.
    [presenter presentViewController:controller animated:YES completion:nil];
}

@end
