//
//  MyNavigationController.m
//  Hollywood Shuffle
//
//  Created by AC on 11/7/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/*
- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    NSLog(@"%@", [self parentViewController]);
    
    if (self)
    {
        //other initialization
        NSLog(@"self created");
    }
    
    return self;
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supported interface orientations called @%d", UIInterfaceOrientationMaskLandscape);
    //return UIInterfaceOrientationMaskLandscape;
    return UIInterfaceOrientationMaskLandscape;
}
/*
- (BOOL)shouldAutorotate
{
    NSLog(@"device orientation is =  %d", [[UIDevice currentDevice] orientation]);
    
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }else
    {
        return NO;
    }
}
*/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}


@end
