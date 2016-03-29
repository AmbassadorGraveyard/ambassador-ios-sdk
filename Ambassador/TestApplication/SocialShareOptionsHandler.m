//
//  SocialShareOptionsHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SocialShareOptionsHandler.h"
#import "SocialCell.h"

@interface SocialShareOptionsHandler() <SocialCellDelegate>

// Private properties
@property (nonatomic, strong) NSMutableArray * fullArray;
@property (nonatomic, strong) NSMutableArray * onArray;

@end


@implementation SocialShareOptionsHandler


#pragma mark - LifeCycle

- (id)initWithArrayOrder:(NSMutableArray*)fullArray onArray:(NSMutableArray*)onArray {
    self = [super init];
    self.fullArray = fullArray;
    self.onArray = onArray;
    
    return self;
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fullArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"socialCell"];
    
    // Gets boolean to tell cell if channel is enabled or not
    BOOL isEnabled = [self.onArray containsObject:self.fullArray[indexPath.row]];
    
    [cell setUpCellWithName:self.fullArray[indexPath.row] isEnabled:isEnabled orderIndex:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

// Hides default delete button while editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - TableView Delegate

// Handles what to do when rows are being re-ordered
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    // Updates the order of the full social array
    NSString *stringToMove = self.fullArray[sourceIndexPath.row];
    [self.fullArray removeObjectAtIndex:sourceIndexPath.row];
    [self.fullArray insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    // Creates a new array with correct order and enabled channels
    NSMutableArray *newOrderArray = [[NSMutableArray alloc] init];
    for (NSString *channel in self.fullArray) {
        if ([self.onArray containsObject:channel]) {
            [newOrderArray addObject:channel];
        }
    }
    
    // Checks if delegate is implementing function and passes back new order of array
    if ([self.delegate respondsToSelector:@selector(socialShareHandlerUpdated:)]) {
        [self.delegate socialShareHandlerUpdated:newOrderArray];
    }
}

// Keeps row from shifting right when editing
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - Social Cell Delegate

- (void)socialChannel:(NSString *)channel enableStatusUpdated:(BOOL)enabled orderIndex:(NSInteger)index {
    // Decides whether to add or remove to enabled channels based on switch
    if (enabled) {
        [self.onArray addObject:channel];
    } else {
        [self.onArray removeObject:channel];
    }
    
    // Tells delegate to update social array if responds
    if ([self.delegate respondsToSelector:@selector(socialChannel:enableStatusUpdated:orderIndex:)]) {
        [self.delegate socialShareHandlerEnabledObjectsUpdated:self.onArray];
    }
}

@end
