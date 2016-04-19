//
//  CampaignListController.h
//  Ambassador
//
//  Created by Jake Dunahee on 3/25/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CampaignObject.h"

@protocol CampaignListDelegate <NSObject>

- (void)campaignListCampaignChosen:(CampaignObject*)campaignObject;

@end


@interface CampaignListController : UIViewController

@property (nonatomic, weak) id<CampaignListDelegate> delegate;

@end
