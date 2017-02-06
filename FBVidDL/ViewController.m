//
//  ViewController.m
//  FBVidDL
//
//  Created by High Jumper on 7/18/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "TSFacebookManager.h"
#import "VideoTableViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (nonatomic, retain) AVPlayerViewController* playerViewController;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)viewWillAppear:(BOOL)animated{
    // Do any additional setup after loading the view, typically from a nib.
    dispatch_async(dispatch_get_main_queue(), ^{
        _playerViewController = [[AVPlayerViewController alloc] init];
        CGRect rect = self.videoPlayerView.frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        _playerViewController.view.frame = rect;
        _playerViewController.showsPlaybackControls = YES;
        [_videoPlayerView addSubview:_playerViewController.view];
        //    _videoPlayerView.autoresizesSubviews = YES;
    });
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)facebookLogin:(id)sender {
    [[TSFacebookManager sharedManager] loginToFacebookInBackgroundWithCompletion:^(BOOL success) {
        if (success == true) {
            NSLog(@"Login successed");
        } else {
            NSLog(@"Login failed");
        }
    }];
}

- (IBAction)logoutAction:(UIButton *)sender {
    [[TSFacebookManager sharedManager] logoutOfFacebookInBackgroundWithCompletion:^(BOOL success) {
        NSLog(@"Logout successfully!");
    }];
    
}
- (IBAction)fetchVideoAction:(id)sender {
   [[TSFacebookManager sharedManager] fetchMyFacebookVideosInBackgroundWithCompletion:^(BOOL success) {
       
   }];
}
- (IBAction)downloadVideoAction:(id)sender {
    [[TSFacebookManager sharedManager] fetchMyFacebookVideosInBackgroundWithCompletion:^(BOOL success) {
        if (success == true) {
            [[TSFacebookManager sharedManager] downloadMyVideoAtIndex:1 completion:^(NSData *data) {
                if (data != nil) {
                    NSLog(@"Download successed");
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *videoFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
                    [data writeToFile:videoFile atomically:YES];
                    NSURL* url = [NSURL fileURLWithPath:videoFile];
                    
                    _playerViewController.player = [AVPlayer playerWithURL:url];
                    [_playerViewController.player play];
                } else {
                    NSLog(@"Video Download failed");
                }
            }];
        } else {
            NSLog(@"Fetch video failed");
        }
    }];
}
- (IBAction)fetchMyVideoAction:(id)sender {
    [[TSFacebookManager sharedManager] fetchMyFacebookVideosInBackgroundWithCompletion:^(BOOL success) {
        NSArray* videoArray = [TSFacebookManager sharedManager].myVideos;
        if (success == true) {
            [self presendVideoTableViewControllerAction:videoArray];
        }
    }];
}

- (IBAction)fetchTaggedVideoAction:(id)sender {
    [[TSFacebookManager sharedManager] fetchMyFBTaggedVideosInBackgroundWithCompletion:^(BOOL success) {
        NSArray* videoArray = [TSFacebookManager sharedManager].myTaggedVideos;
        if (success == true) {
            [self presendVideoTableViewControllerAction:videoArray];
        }
    }];
    
}

-(void)presendVideoTableViewControllerAction:(NSArray*)videos {
    VideoTableViewController* videoVC = (VideoTableViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"VideoTableViewController"];
    videoVC.videoArray = videos;
    [self.navigationController pushViewController:videoVC animated:true];
}


@end
