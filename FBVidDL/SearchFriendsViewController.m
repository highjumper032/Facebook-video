//
//  SearchFriendsViewController.m
//  FBVidDL
//
//  Created by bluestar on 7/29/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "TSFacebookManager.h"

@implementation SearchFriendsViewController
{
    NSArray* friendsList;
}
@synthesize friendsTable;
@synthesize searchBar;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate = self;
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    
    [[TSFacebookManager sharedManager] searchForFacebookFriends:@"" completion:^(BOOL success, NSArray *resultArray) {
        if (success == true){
            self->friendsList = resultArray;
            [self.friendsTable reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (friendsList != nil) {
        return friendsList.count;
    } else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    cell.textLabel.text = (NSString*)[((NSDictionary*)[friendsList objectAtIndex: indexPath.row]) objectForKey:@"name"];
    return cell;
}
#pragma mark -
#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[TSFacebookManager sharedManager] fetchFacebookVideosInBackgroundForFriendAtIndex:[indexPath row] completion:^(BOOL success) {        
    }];
}

#pragma mark -
#pragma mark - SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [[TSFacebookManager sharedManager] searchForFacebookFriends:searchText completion:^(BOOL success, NSArray *resultArray) {
        if (success == true) {
            friendsList = resultArray;
            [self.friendsTable reloadData];
        }
    }];
}

@end
