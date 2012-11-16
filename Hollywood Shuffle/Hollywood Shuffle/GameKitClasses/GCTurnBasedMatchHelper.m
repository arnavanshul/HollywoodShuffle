//
//  GCTurnBasedMatchHelper.m
//  Hollywood Shuffle
//
//  Created by AC on 9/26/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "GCTurnBasedMatchHelper.h"
#import "QuickPlayViewController.h"
#import "StandardPlayViewController.h"
#include <GameKit/GameKit.h>
#include "AppDelegate.h"

@implementation GCTurnBasedMatchHelper

@synthesize gameCenterAvailable, currentMatch, delegate;

static GCTurnBasedMatchHelper *sharedHelper = nil;

+ (GCTurnBasedMatchHelper *) sharedInstance
{
    if (!sharedHelper)
    {
        sharedHelper = [[GCTurnBasedMatchHelper alloc] init];
    }
    
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init
{
    if ((self = [super init]))
    {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(authenticationChanged) name: GKPlayerAuthenticationDidChangeNotificationName object:nil];
            gameTypeSelected = -1;
        }
    }
    return self;
}

- (BOOL) isLocalPlayerAuthenticated
{
    if ([GKLocalPlayer localPlayer].isAuthenticated)
    {
        return true;
    }else
    {
        return false;
    }
}

- (void)authenticationChanged
{
    NSLog(@"local player is authenticated %d", [GKLocalPlayer localPlayer].isAuthenticated);
    NSLog(@"local variable is authenticated. %d", userAuthenticated);
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
    {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }/*else if (![GKLocalPlayer localPlayer].isAuthenticated)
    {
        void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError *error)
        {
            NSLog(@"%@", error);
            GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
            ev.delegate = self;
        };
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: setGKEventHandlerDelegate];
    }*/
}

- (void)authenticateLocalUser
{
    if (!gameCenterAvailable)
        return;
    
    NSLog(@"Authenticating local user for turn based match...");
    
    void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError *error)
    {
        NSLog(@"in set gk event handler %@", error);
        GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
        ev.delegate = self;
    };
    
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        if([[GKLocalPlayer localPlayer] respondsToSelector:@selector(authenticateWithCompletionHandler:)])
        {
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: setGKEventHandlerDelegate];
            
        }else
        {
            [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error)
             {
                 NSLog(@"%@", [error description]);
                 if (viewController != nil)
                 {
                     //[self showAuthenticationDialogWhenReasonable: viewController];
                     //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                     //[appDelegate.window.rootViewController presentModalViewController:viewController animated:true];
                     NSLog(@"show authentication dialog");
                     
                 }else if ([GKLocalPlayer localPlayer].isAuthenticated)
                 {
                     //[self authenticatedPlayer: [GKLocalPlayer localPlayer]];
                     NSLog(@"player authenticated");
                     
                 }else
                 {
                     //[self disableGameCenter];
                     NSLog(@"disable game center");
                 }
             }];
        }
    
    } else
    {
        setGKEventHandlerDelegate(nil);
    }
}

- (void) clearFinishedMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
     {
         for (GKTurnBasedMatch *match in matches)
         {
             if (match.status == GKTurnBasedMatchStatusEnded)
             {
                 [match removeWithCompletionHandler:^(NSError *error) {
                     if(error)
                     {
                         NSLog(@"%@", error);
                     }
                 }];
             }
         }
     }];
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers gameType:(int)gameType viewController:(UIViewController *)viewController
{
    if (!gameCenterAvailable)
    {
        return;
    }
    
    //THE FOLLOWING CODE REMOVES ALL THE EXISTING GAMES WITH DETERMINED RESULTS AT START UP.
    
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
     {
         [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
          {
              for (GKTurnBasedMatch *match in matches)
              {
                  NSLog(@"match id = %@", match.matchID);
                  NSLog(@"match status = %d", match.status);
                  if (match.status != GKTurnBasedMatchOutcomeNone)
                  {
                      [match removeWithCompletionHandler:^(NSError *error)
                       {
                           NSLog(@"%@", error.localizedDescription);
                       }];
                  }
              }
          }];
     }];
    
    presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    request.playersToInvite = nil;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    /*
    for(UIView *view in [mmvc.view subviews])
    {
        [view removeFromSuperview];
    }
    */
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    gameTypeSelected = gameType;
    
    [presentingViewController presentModalViewController:mmvc animated:YES];
}


- (BOOL) isMyTurnforMatch: (GKTurnBasedMatch *)match
{
    if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
    {
        return true;
    }else
    {
        return false;
    }
}


#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"did find match, %@", match);
    self.currentMatch = match;
    NSLog(@"no. of participants is = %d", [match.participants count]);
    
    if (gameTypeSelected == 1)
    {
        QuickPlayViewController *game = [[QuickPlayViewController alloc] init];
        [presentingViewController.navigationController pushViewController:game animated:YES];
    }else
    {
        StandardPlayViewController *game = [[StandardPlayViewController alloc] init];
        [presentingViewController.navigationController pushViewController:game animated:YES];
    }
    
    GKTurnBasedParticipant *firstPlayer =  [match.participants objectAtIndex:0];
    
    if(firstPlayer.lastTurnDate)
    {
        NSLog(@"Existing match");
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
        {
            NSLog(@"%@", delegate);
            [delegate takeTurn:match];
        }else
        {
            [delegate layoutMatch:match];
        }
    }else
    {
        NSLog(@"calling delegate's enter new match %@", delegate);
        
        [delegate enterNewGame: match];
    }
    
    for (GKTurnBasedParticipant *temp in match.participants)
    {
        NSLog(@"participant = %@", temp.playerID);
    }
    
    NSLog(@"match status %d", match.status);
    /*
    [currentMatch endTurnWithNextParticipant:[match.participants objectAtIndex:1] matchData:nil completionHandler:nil];
    
    [currentMatch endTurnWithNextParticipant:[match.participants objectAtIndex:1] matchData:nil completionHandler:nil];
     */
}

-(void)turnBasedMatchmakerViewControllerWasCancelled: (GKTurnBasedMatchmakerViewController *)viewController
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"playerquitforMatch, %@, %@", match, match.currentParticipant);
    
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part;
    
    for (int i = 0; i < [match.participants count]; i++)
    {
        part = [match.participants objectAtIndex: (currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit)
        {
            break;
        }
    }
    
    [match participantQuitInTurnWithOutcome: GKTurnBasedMatchOutcomeQuit nextParticipant:part matchData:match.matchData completionHandler:nil];
    //[match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:nil];
}



#pragma mark GKTurnBasedEventHandlerDelegate



-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    NSLog(@"new invite");
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Turn has happened");
    
    if ([match.matchID isEqualToString:currentMatch.matchID])
    {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
        {
            // it's the current match and it's our turn now
            self.currentMatch = match;
            [delegate takeTurn:match];
        } else
        {
            // it's the current match, but it's someone else's turn
            self.currentMatch = match;
            [delegate layoutMatch:match];
        }
    } else
    {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            [delegate sendNotice:@"It's your turn for another match" forMatch:match];
        } else
        {
            // it's the not current match, and it's someone else's
            // turn
        }
    }
}


-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive
{
    NSLog(@"%@", match.participants);
    
    if ([match.matchID isEqualToString:currentMatch.matchID])
    {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
        {
            // it's the current match and it's our turn now
            self.currentMatch = match;
            [delegate takeTurn:match];
        } else
        {
            // it's the current match, but it's someone else's turn
            self.currentMatch = match;
            [delegate layoutMatch:match];
        }
    } else
    {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            [delegate sendNotice:@"It's your turn for another match" forMatch:match];
        } else
        {
            // it's the not current match, and it's someone else's
            // turn
        }
    }
}


-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    
    NSLog(@"Game has ended");
    
    if ([match.matchID isEqualToString:currentMatch.matchID]) {
        [delegate receiveEndGame:match];
    } else {
        [delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
}



@end