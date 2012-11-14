//
//  AppDelegate.h
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

typedef enum deviceTypes
{
    IPHONE,
    IPAD
} DeviceType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableDictionary *all52Cards;
    Reachability *internetReachable, *hostReachable;
    DeviceType deviceType;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableDictionary *all52Cards;
@property (nonatomic, assign) DeviceType deviceType;
-(BOOL) connectedToInternet;
@end
