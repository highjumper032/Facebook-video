//
//  TSFacebookManager.m
//  FBVidDL
//
//  Created by High Jumper on 7/18/16.
//  Copyright © 2016 Tapsmith LLC. All rights reserved.
//

#import "TSFacebookManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define FBVideoTypeUpload @"uploaded"
#define FBVideoTypeTagged @"tagged"

@implementation TSFacebookManager
{
    NSArray * permissions;
    NSString * fb_id;
    FBSDKLoginManager* loginManager;
    NSArray* myFriends;
}

#pragma mark - Singleton -

+ (TSFacebookManager *)sharedManager {
    
    static TSFacebookManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends", @"user_videos", @"user_photos", @"user_posts"]];
    });
    
    return _sharedManager;
}

- (instancetype)initWithPermissions:(NSArray *)permissionsArray
{
    self = [super init];
    if (self) {
        permissions = permissionsArray;
        fb_id = [[NSBundle mainBundle].infoDictionary objectForKey:@"FacebookAppID"];
        loginManager = [[FBSDKLoginManager alloc] init];
        // If show login view as WebView
        //loginManager.loginBehavior = FBSDKLoginBehaviorWeb;
    }
    return self;
}

#pragma mark -
#pragma mark - login to facebook as smoothly as possible, preferably without leaving the app

- (void)loginToFacebookInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock {
    
    if ( [FBSDKAccessToken currentAccessToken] != nil ) {
        //For debugging, when we want to ensure that facebook login always happens
        #if DEBUG
            [loginManager logOut];
        #else
            completionBlock(true);
            return;
        #endif
    }
    [loginManager logInWithReadPermissions: permissions fromViewController:nil
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Login process error");
             completionBlock(false);
         } else if (result.isCancelled) {
             NSLog(@"Login cancelled");
             completionBlock(false);
         } else {
             NSLog(@"Logged in");
             // If you ask for multiple permissions at once, you
             // should check if specific permissions missing
             BOOL allPermsGranted = true;
             NSArray* grantPermissions = result.grantedPermissions.allObjects;
             for (NSString* permission in permissions) {
                 if ( [grantPermissions containsObject:permission] == NO) {
                     allPermsGranted = false;
                     break;
                 }
             }
             if (allPermsGranted == true) {
                 completionBlock(true);
             } else {
                 //The user did not grant all permissions requested
                 //Discover which permissions are granted
                 //and if you can live without the declined ones
                 completionBlock(false);
             }
         }
     }];
}

-(void)logoutOfFacebookInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock{
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    
    [loginManager logOut];
    
    completionBlock(true);
}
#pragma mark -
#pragma mark - fetch videos so that they can be displayed with thumbnails in a collectionView, then later downloaded in full. Result saved to "myVideos"

-(void)fetchMyFacebookVideosInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock
{
    [self fetchFacebookVideosInBackgroundForUserAtID:@"me" videoType:FBVideoTypeUpload completion:^(BOOL success, id result) {
        if (success == true) {
            NSLog(@"fetch my videos: %@", result);
            if ([(NSDictionary*)result objectForKey:@"data"]) {
                self.myVideos = (NSArray*)[(NSDictionary*)result objectForKey:@"data"];
            }
            completionBlock(true);
        } else {
            NSLog(@"fetch my videos: failed");
            completionBlock(false);
        }
    }];
}

#pragma mark -
#pragma mark - fetch tagged videos

-(void)fetchMyFBTaggedVideosInBackgroundWithCompletion:(FBIsSuccessBlock)completionBlock {
    [self fetchFacebookVideosInBackgroundForUserAtID:@"me" videoType:FBVideoTypeTagged completion:^(BOOL success, id result) {
        if (success == true) {
            NSLog(@"fetch my tagged videos: %@", result);
            if ([(NSDictionary*)result objectForKey:@"data"]) {
                self.myTaggedVideos = (NSArray*)[(NSDictionary*)result objectForKey:@"data"];
            }
            completionBlock(true);
        } else {
            NSLog(@"fetch my tagged videos: failed");
            completionBlock(false);
        }
    }];
}

-(void)fetchFacebookVideosInBackgroundForUserAtID:(NSString*)userID videoType:(NSString*)type completion:(FBCompletionBlock)completionBlock
{
    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSString* fields = @"id,picture,source,title,length";
        NSDictionary* params = @{@"type" : [NSString stringWithFormat:@"%@", type],
                                 @"fields" : fields};
        NSString* graphPath = [NSString stringWithFormat:@"/%@/videos", userID];
        [self FBGraphRequestHandler:graphPath parameters:params withCompletion: completionBlock];
        
    } else {
        completionBlock(false, nil);
    }
}


#pragma mark - Deprecated function
#pragma mark - fetch videos of facebook friends from index

-(void)fetchFacebookVideosInBackgroundForFriendAtIndex:(NSInteger)index completion:(FBIsSuccessBlock)completionBlock {
    
//    _selectedFriend = [[_searchedFriends objectAtIndex:index] mutableCopy];
//    #if DEBUG
//        NSString* userID = @"750290283";
//    #else
//        NSString* userID = [(NSDictionary*)_selectedFriend objectForKey:@"id"];
//    #endif
//    
//    [self fetchFacebookVideosInBackgroundForUserAtID:userID videoType:@"uploaded" completion:^(BOOL success, id result) {
//        if (success == true) {
//            NSLog(@"fetch friend's videos: %@", result);
//            if ([(NSDictionary*)result objectForKey:@"data"]) {
//                [_selectedFriend setObject:(NSArray*)[(NSDictionary*)result objectForKey:@"data"] forKey:@"videos"];
//            }
//            completionBlock(true);
//        } else {
//            NSLog(@"fetch friend's videos: failed");
//            completionBlock(false);
//        }
//    }];
}

#pragma mark -
#pragma mark - Filter facebook friends with name. if search "Daniel", all my friends with Daniel as part of their name will pop up, so like "Daniel Mayer" and "Daniel Smith"

-(void)searchForFacebookFriends:(NSString *)searchTerm completion:(void(^)(BOOL success, NSArray* resultArray))completion{
    if (myFriends == nil) {
        [self getMyFriendsWithCompletion:^(BOOL success, id result) {
            if (success == true){
                myFriends = (NSArray*)[(NSDictionary*)result objectForKey:@"data"];
                #if DEBUG
                    //If there are friends  using app
                    if (myFriends.count > 0){
                        self.searchedFriends = [self filterFriendsWithString:searchTerm friendsArray:myFriends];
                        completion(true, self.searchedFriends);
                    
                    //If no friends using app, search friends in taggable friends
                    } else {
                        [self getMyTaggableFriendsWithCompletion:^(BOOL success,id result1) {
                            if (success == true){
                                myFriends = (NSArray*)[(NSDictionary*)result1 objectForKey:@"data"];
                                self.searchedFriends = [self filterFriendsWithString:searchTerm friendsArray:myFriends];
                                completion(true, self.searchedFriends);
                            } else {
                                completion(false, nil);
                            }
                        }];
                    }
                #else
                    self.searchedFriends = [self filterFriendsWithString:searchTerm friendsArray:myFriends];
                    NSLog(@"searched friends: %@", self.searchedFriends);
                    completion(true, self.searchedFriends);
                #endif
            } else {
                completion(false, nil);
            }
        }];
    } else {
        self.searchedFriends = [self filterFriendsWithString:searchTerm friendsArray:myFriends];
        completion(true, self.searchedFriends);
    }
}

-(void)getMyTaggableFriendsWithCompletion:(FBCompletionBlock)completionBlock {
    
    NSString* fields = @"id,name,picture";
    NSDictionary* params = @{@"fields" : fields, @"limit":@300};
    
    [self getMySomethingFromFacebook:@"taggable_friends" parameters:params withCompletion:^(BOOL success, id result) {
        if (success == true) {
            NSLog(@"fetched friends:%@", result);
            completionBlock(true, result);
        } else {
            NSLog(@"fetch friends failed");
            completionBlock(false, nil);
        }
    }];
}

-(void)getMyFriendsWithCompletion:(FBCompletionBlock)completionBlock
{
    NSString* fields = @"id,name,picture";
    NSDictionary* params = @{@"fields" : fields, @"limit":@300};
    
    [self getMySomethingFromFacebook:@"friends" parameters:params withCompletion:^(BOOL success, id result) {
        if (success == true) {
            NSLog(@"fetched friends:%@", result);
            completionBlock(true, result);
        } else {
            NSLog(@"fetch friends failed");
            completionBlock(false, nil);
        }
    }];
}

-(NSArray*)filterFriendsWithString:(NSString*)searchStr friendsArray: (NSArray*)friends
{
    /* If search string is empty, return entire array */
    if ([searchStr isEqualToString:@""]) {
        NSLog(@"searched friends: %@", friends);
        return friends;
    }
    /* Filter array : Pick up objects that prefix of name is same with searchStr*/
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings) {
        return [((NSString*)[(NSDictionary*)evaluatedObject objectForKey:@"name"]).lowercaseString hasPrefix:searchStr.lowercaseString ];
    }];
    NSArray* filteredArray = [friends filteredArrayUsingPredicate:predicate];
    NSLog(@"searched friends: %@", filteredArray);
    
    return filteredArray;
}

#pragma mark -
#pragma mark - Download my video with index

-(void)downloadMyVideoAtIndex:(NSInteger)integer completion:(CompleteWithDataBlock)completionBlock {
    //Video download stream
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString* videoUrlStr = [(NSDictionary*)[_myVideos objectAtIndex:integer] objectForKey:@"source"];
        NSURL* videoURL = [NSURL URLWithString:videoUrlStr];
        NSData* videoData = [NSData dataWithContentsOfURL:videoURL];
        
        if (videoData != nil) {
            completionBlock(videoData);
        } else {
            completionBlock(nil);
        }
    });
}
-(void)downloadSelectedFriendsVideoAtIndex:(NSInteger)integer completion:(CompleteWithDataBlock)completionBlock {
    
}

#pragma mark -
#pragma mark - FBSDKGraph API GET request handler
-(void)getMySomethingFromFacebook:(NSString*)requestType parameters:(NSDictionary*)params withCompletion:(void(^)(BOOL success, id result))completionBlock {
    if ([FBSDKAccessToken currentAccessToken] != nil)
    {
        NSString* graphPath = [NSString stringWithFormat:@"/me/%@", requestType];
        [self FBGraphRequestHandler:graphPath parameters:params withCompletion:completionBlock];
    } else {
        completionBlock(false, nil);
    }
}

-(void)FBGraphRequestHandler:(NSString*)path parameters:(NSDictionary*)params withCompletion:(FBCompletionBlock)completionBlock{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:path
                                  parameters: params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            completionBlock(true, result);
        } else {
            completionBlock(false, nil);
        }
    }];
}

@end
