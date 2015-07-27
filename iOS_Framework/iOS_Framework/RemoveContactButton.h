//
//  RemoveContactButton.h
//  ipadcontacts
//
//  Created by Diplomat on 7/10/15.
//  Copyright (c) 2015 Austin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoveContactButton : UIButton

// Added to allow extra data passing on from selected tablecells via
// these buttons used in the accessory view
@property NSIndexPath *indexPath;
@property NSString *value;

@end
