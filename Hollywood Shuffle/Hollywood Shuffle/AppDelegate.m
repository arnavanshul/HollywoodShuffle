    //
//  AppDelegate.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "AppDelegate.h"
#import "GCTurnBasedMatchHelper.h"
#import "GCRealTimeMatchHelper.h"
#import "ActorObject.h"
#import "LoginScreenViewController.h"
#import "Reachability.h"
#import "MyNavigationController.h"

@implementation AppDelegate
@synthesize all52Cards, deviceType;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if([[[UIDevice currentDevice] name] rangeOfString:@"iPad"].location != NSNotFound)
    //if([[[UIDevice currentDevice] name] isEqualToString:@"iPad Simulator"])
    {
        deviceType = IPAD;
    }else
    {
        deviceType = IPHONE;
    }
    
    all52Cards = [[NSMutableDictionary alloc] init];
    
    [[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUser];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //MyNavigationController *navController = (MyNavigationController *)[[UINavigationController alloc] init];
    
    LoginScreenViewController *lg = [[LoginScreenViewController alloc] init];
    
    //[navController pushViewController:lg animated:YES];
    
    MyNavigationController *navController = [[MyNavigationController alloc] initWithRootViewController:lg];
    
    navController.navigationBarHidden = YES;
    NSLog(@"%@", [navController viewControllers]);
    
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if([self connectedToInternet])
    {
        if([all52Cards count] == 0)
        {
            [self getAllActors];
        }
    }else
    {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"NOT CONNECTED TO INTERNET" message:@"You have to be connected to internet to play this game!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noInternet show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSLog(@"supportedInterfaceOrientationsForWindow");
    //return  UIInterfaceOrientationMaskLandscape;
    //return  UIInterfaceOrientationMaskAllButUpsideDown;
    
    if([[GCTurnBasedMatchHelper sharedInstance] isLocalPlayerAuthenticated])
    {
        return UIInterfaceOrientationMaskLandscape;
    }else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (void) getAllActors
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://tblr.asu.edu/hollywoodshuffle/actors.php"]];
    
    if (data) {
        NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if ([[tempDict objectForKey:@"success"] integerValue] == 1)
        {
            NSArray *tempActorArray = [tempDict objectForKey:@"actorlist"];
            
            for (NSDictionary *actorDict in tempActorArray)
            {
                ActorObject *tempActor = [[ActorObject alloc] init];
                tempActor.actorId = [[actorDict objectForKey:@"actor_id"] integerValue];
                [tempActor.actorName setString: [actorDict objectForKey:@"actor_name"]];
                tempActor.actorImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", tempActor.actorId]];
                
                [all52Cards setObject:tempActor forKey:[NSNumber numberWithInteger: tempActor.actorId]];
            }
        }
    }
}

- (BOOL)connectedToInternet
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


@end
