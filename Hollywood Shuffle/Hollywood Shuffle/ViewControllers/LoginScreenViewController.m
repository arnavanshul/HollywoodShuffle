//
//  LoginScreenViewController.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ActorObject.h"
@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    ActorObject *tempActor = [[appDelegate all52Cards] objectForKey:[NSNumber numberWithInteger:101]];
    
    tempActor.actorImageView.frame = CGRectMake(10, 10, 64, 90);
    tempActor.actorImageView.layer.borderColor = [UIColor redColor].CGColor;
    //tempActor.actorImageView.backgroundColor = [UIColor redColor];
    
    //[self.view addSubview: tempActor.actorImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape; 
}

- (BOOL)shouldAutorotate
{
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationMaskLandscape)
    {
        return YES;
    }else
    {
        return NO;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

@end
