//
//  TSFacebookManager.h
//  FBVidDL
//
//  Created by High Jumper on 7/18/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FBIsSuccessBlock)(BOOL success);
typedef void (^FBCompletionBlock)(BOOL success , id result);
typedef void (^CompleteWithDataBlock)(NSData * data);

/*
    This class is Facebook API Manager that access to data(friends, videos) from facebook
*/
@interface TSFacebookManager : NSObject

    @property (nonatomic, strong, readwrite) NSArray * myVideos;
    @property (nonatomic, strong, readwrite) NSArray * myTaggedVideos;

    @property (nonatomic, strong, readwrite) NSArray * friendsVideos;
    @property (nonatomic, strong, readwrite) NSArray * searchedFriends;
    @property (nonatomic, strong, readwrite) NSMutableDictionary* selectedFriend;

    +(TSFacebookManager *)sharedManager;

    //login to facebook as smoothly as possible, preferably without leaving the app
    -(void)loginToFacebookInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock;
    -(void)logoutOfFacebookInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock;


    //fetch so that they can be displayed with thumbnails in a collectionView, then later downloaded in full. Result saved to "myVideos"
    -(void)fetchMyFacebookVideosInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock;
    -(void)fetchMyFBTaggedVideosInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock;

    -(void)searchForFacebookFriends:(NSString *)searchTerm completion:(void(^)(BOOL success, NSArray* resultArray))completionn;

    -(void)fetchFacebookVideosInBackgroundForFriendAtIndex:(NSInteger)index completion:(FBIsSuccessBlock)completionBlock; //sets the selectedFriend property

    -(void)downloadMyVideoAtIndex:(NSInteger)integer completion:(CompleteWithDataBlock)completionBlock;

    -(void)downloadSelectedFriendsVideoAtIndex:(NSInteger)integer completion:(CompleteWithDataBlock)completionBlock;

@end
