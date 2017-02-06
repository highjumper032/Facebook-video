//
//  VideoTableViewController.m
//  FBVidDL
//
//  Created by johan on 7/30/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import "VideoTableViewController.h"
#import "TSFacebookManager.h"
#import "VideoViewController.h"

@interface VideoTableViewController ()
@end

@implementation VideoTableViewController
{
    UIActivityIndicatorView* activityIndicator;
}
@synthesize videoArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (videoArray != nil){
        return videoArray.count;
    }
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell"  forIndexPath:indexPath];
//     Configure the cell...
    NSDictionary* video = (NSDictionary*)videoArray[indexPath.row];
    
    int videoLengthAsSec = [[video objectForKey:@"length"] intValue] ;
    
    if ([video objectForKey:@"title"] == nil){
        videoCell.textLabel.text = @"untitled";
    } else {
        videoCell.textLabel.text = (NSString*)[video objectForKey:@"title"];
    }
    videoCell.detailTextLabel.text = [self getDateFormatedStringFromTimestamp:videoLengthAsSec];
    
    return videoCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{    
  
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = self.view.bounds;
    [self.view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    [[TSFacebookManager sharedManager] downloadMyVideoAtIndex:indexPath.row completion:^(NSData *data) {
        if (data != nil) {
            NSLog(@"Download successed");
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *videoFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
            [data writeToFile:videoFile atomically:YES];
            
             dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
                
                [self presentVideoView];
             });
            
        } else {
            NSLog(@"Video Download failed");
        }
    }];
    
}

-(void)presentVideoView {
    VideoViewController* videoVC = (VideoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
    [self.navigationController pushViewController:videoVC animated:true];
}

/*
    Get formatted string from time stamp
*********/

-(NSString*)getDateFormatedStringFromTimestamp:(int)seconds {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (seconds >= 3600) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [formatter stringFromDate:date];
}
@end
