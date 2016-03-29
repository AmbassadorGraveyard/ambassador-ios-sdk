//
//  SocialShareOptionsHandler.m
//  Ambassador
//
//  Created by Jake Dunahee on 3/28/16.
//  Copyright © 2016 Ambassador. All rights reserved.
//

#import "SocialShareOptionsHandler.h"
#import "SocialCell.h"

@interface SocialShareOptionsHandler()

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
    [cell setUpCellWithName:self.fullArray[indexPath.row] isEnabled:YES];
    
    return cell;
}

// Hides default delete button while editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - TableView Delegate

// Handles what to do when rows are being re-ordered
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSString *stringToMove = self.fullArray[sourceIndexPath.row];
    [self.fullArray removeObjectAtIndex:sourceIndexPath.row];
    [self.fullArray insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    // Checks if delegate is implementing function and passes back new order of array
    if ([self.delegate respondsToSelector:@selector(socialShareHandlerUpdated:)]) {
        [self.delegate socialShareHandlerUpdated:self.fullArray];
    }
}

// Keeps row from shifting right when editing
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
