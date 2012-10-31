//
//  GCRealTimeMatchHelper.m
//  Hollywood Shuffle
//
//  Created by AC on 10/3/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "GCRealTimeMatchHelper.h"
#import <GameKit/GameKit.h>

@implementation GCRealTimeMatchHelper
@synthesize gameCenterAvailable, delegate, presentingViewController;

static GCRealTimeMatchHelper *sharedHelper = nil;
+ (GCRealTimeMatchHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCRealTimeMatchHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
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
            [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
    {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

- (void)authenticateLocalUser
{
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user for real time match...");
    
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else
    {
        NSLog(@"Already authenticated!");
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController
                       delegate:(id<GCRealTimeMatchHelperDelegate>)theDelegate
{
    if (!gameCenterAvailable)
    {
        return;
    }
    
    matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    delegate = theDelegate;
    //[presentingViewController dismissModalViewControllerAnimated:NO];
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    NSLog(@"%@", mmvc);
    NSLog(@"%@", viewController);
    NSLog(@"%@", self.presentingViewController);
    [self.presentingViewController presentModalViewController:mmvc animated:YES];
    //[presentingViewController.navigationController pushViewController:mmvc animated:YES];
}

- (void)setDelegate : (id<GCRealTimeMatchHelperDelegate>)theDelegate
{
    delegate = theDelegate;
}


#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    NSLog(@"%@", presentingViewController);
    [presentingViewController dismissModalViewControllerAnimated:YES];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"%@", self.presentingViewController);
    [presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch
{
    NSLog(@"%@", self.presentingViewController);
    [presentingViewController dismissModalViewControllerAnimated:YES];
    self.match = theMatch;
    match.delegate = self;
    if (!matchStarted && match.expectedPlayerCount == 0)
    {
        NSLog(@"Ready to start match!");
    }
}



#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    if (match != theMatch) return;
    
    [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (match != theMatch) return;
    
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!matchStarted && theMatch.expectedPlayerCount == 0)
            {
                NSLog(@"Ready to start match!");
                [delegate matchStarted];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            matchStarted = NO;
            [delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    if (match != theMatch) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error
{
    
    if (match != theMatch)
    {
        return;
    }
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [delegate matchEnded];
}

@end
