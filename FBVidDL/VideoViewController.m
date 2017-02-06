//
//  VideoViewController.m
//  FBVidDL
//
//  Created by johan on 7/30/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "VideoViewController.h"

@interface VideoViewController ()
@property (nonatomic, retain) AVPlayerViewController* playerViewController;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _playerViewController = [[AVPlayerViewController alloc] init];
    _playerViewController.view.frame = self.view.bounds;
    _playerViewController.showsPlaybackControls = YES;
    [self.view addSubview:_playerViewController.view];
//    self.view.autoresizesSubviews = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *videoFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.m4v"];
    NSURL* url = [NSURL fileURLWithPath:videoFile];

    _playerViewController.player = [AVPlayer playerWithURL:url];
    [_playerViewController.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
