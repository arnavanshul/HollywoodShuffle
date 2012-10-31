//
//  GCRealTimeMatchHelper.h
//  Hollywood Shuffle
//
//  Created by AC on 10/3/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCRealTimeMatchHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end

@interface GCRealTimeMatchHelper : NSObject<GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
    BOOL gameCenterAvailable, userAuthenticated;
    
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    id <GCRealTimeMatchHelperDelegate> delegate;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (nonatomic, retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (nonatomic, retain) id <GCRealTimeMatchHelperDelegate> delegate;

+ (GCRealTimeMatchHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController
                       delegate:(id<GCRealTimeMatchHelperDelegate>)theDelegate;
- (void)setDelegate : (id<GCRealTimeMatchHelperDelegate>)theDelegate;
@end
