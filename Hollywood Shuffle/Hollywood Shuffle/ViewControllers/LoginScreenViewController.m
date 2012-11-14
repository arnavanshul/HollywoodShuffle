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
#import "LoadingScreenViewController.h"

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
    
    NSLog(@"view loaded");
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    bg.image = [UIImage imageNamed:@"login.png"];
    
    UIButton *loginViaFB = [UIButton buttonWithType:UIButtonTypeCustom];
    loginViaFB.frame = CGRectMake(54, 239, 194, 30);
    [loginViaFB addTarget:self action:@selector(loginViaFBClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loginViaMail = [UIButton buttonWithType:UIButtonTypeCustom];
    loginViaMail.frame = CGRectMake(259, 239, 194, 30);
    [loginViaMail addTarget:self action:@selector(loginViaMailClicked) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    ActorObject *tempActor = [[appDelegate all52Cards] objectForKey:[NSNumber numberWithInteger:101]];
    
    tempActor.actorImageView.frame = CGRectMake(10, 10, 64, 90);
    tempActor.actorImageView.layer.borderColor = [UIColor redColor].CGColor;
    //tempActor.actorImageView.backgroundColor = [UIColor redColor];
    
    //[self.view addSubview: tempActor.actorImageView];
    
    if (appDelegate.deviceType == IPAD)
    {
        bg.frame = CGRectMake(0, 0, 1024, 768);
        loginViaFB.frame = CGRectMake(114, 573, 411, 71);
        loginViaMail.frame = CGRectMake(552, 573, 415, 71);
    }
    
    [self.view addSubview: bg];
    [self.view addSubview: loginViaMail];
    [self.view addSubview: loginViaFB];
}


- (void) loginViaMailClicked
{
    [self.navigationController pushViewController:[[LoadingScreenViewController alloc] init] animated:YES];
}


- (void) loginViaFBClicked
{
    [self.navigationController pushViewController:[[LoadingScreenViewController alloc] init] animated:YES];
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

@end
