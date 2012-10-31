//
//  GCTurnBasedMatchHelper.h
//  Hollywood Shuffle
//
//  Created by AC on 9/26/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCTurnBasedMatchHelperDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)receiveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end

@interface GCTurnBasedMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKTurnBasedEventHandlerDelegate>

{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    UIViewController *presentingViewController;
    NSInteger gameTypeSelected;
    GKTurnBasedMatch *currentMatch;
    
    id <GCTurnBasedMatchHelperDelegate> delegate;
}

@property(nonatomic, assign) BOOL gameCenterAvailable;
@property(retain) GKTurnBasedMatch *currentMatch;
@property (nonatomic, retain) id <GCTurnBasedMatchHelperDelegate> delegate;

+ (GCTurnBasedMatchHelper *)sharedInstance;
- (void) authenticateLocalUser;
- (void) authenticationChanged;
- (void) findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers gameType:(int)gameType viewController:(UIViewController *)viewController;
- (BOOL) isMyTurnforMatch: (GKTurnBasedMatch *)match;

@end
