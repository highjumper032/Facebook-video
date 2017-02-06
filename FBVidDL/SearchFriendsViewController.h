//
//  SearchFriendsViewController.h
//  FBVidDL
//
//  Created by bluestar on 7/29/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
    @property (weak, nonatomic) IBOutlet UITableView *friendsTable;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end
