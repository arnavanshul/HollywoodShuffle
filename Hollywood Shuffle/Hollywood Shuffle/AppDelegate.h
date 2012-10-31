//
//  AppDelegate.h
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableDictionary *all52Cards;
    Reachability *internetReachable, *hostReachable;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *all52Cards;
-(BOOL) connectedToInternet;
@end
