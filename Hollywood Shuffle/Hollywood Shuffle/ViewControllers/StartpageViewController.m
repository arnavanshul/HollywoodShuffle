//
//  StartpageViewController.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "StartpageViewController.h"
#import "GCTurnBasedMatchHelper.h"
#import "GCRealTimeMatchHelper.h"
#import "AppDelegate.h"
#import "QuickPlayViewController.h"

@interface StartpageViewController ()

@end

@implementation StartpageViewController

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
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    bg.image = [UIImage imageNamed:@"start_screen_background.png"];
    
    UIButton *backTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    backTemp.frame = CGRectMake(0, 0, 300, 320);
    backTemp.backgroundColor = [UIColor clearColor];
    
    UIButton *quickPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    quickPlayButton.frame = CGRectMake(305, 144, 175, 35);
    [quickPlayButton setBackgroundColor: [UIColor clearColor]];
    [quickPlayButton setBackgroundImage:[UIImage imageNamed:@"b_1.png"] forState:UIControlStateNormal];
    [quickPlayButton addTarget:self action:@selector(quickPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *standardPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    standardPlayButton.frame = CGRectMake(305, 179, 175, 35);
    [standardPlayButton setBackgroundColor: [UIColor clearColor]];
    [standardPlayButton setBackgroundImage:[UIImage imageNamed:@"b_2.png"] forState:UIControlStateNormal];
    [standardPlayButton addTarget:self action:@selector(standardPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tutorialButton = [UIButton buttonWithType: UIButtonTypeCustom];
    tutorialButton.frame = CGRectMake(305, 214, 175, 35);
    [tutorialButton setBackgroundColor: [UIColor clearColor]];
    [tutorialButton setBackgroundImage:[UIImage imageNamed:@"b_3.png"] forState:UIControlStateNormal];
    
    UIButton *settingsButton = [UIButton buttonWithType: UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(305, 249, 175, 35);
    [settingsButton setBackgroundColor: [UIColor clearColor]];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"b_4.png"] forState:UIControlStateNormal];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"%f, %f", screenWidth, screenHeight);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if([[[UIDevice currentDevice] name] rangeOfString:@"iPad"].location != NSNotFound)
    //if([[[UIApplication sharedApplication] delegate] deviceType] == )
    //if(appDelegate.deviceType == IPAD)
    {
        bg.frame = CGRectMake(0, 0, 1024, 768);
        backTemp.frame = CGRectMake(0, 0, 512, 768);
        quickPlayButton.frame = CGRectMake(674, 305, 350, 70);
        standardPlayButton.frame = CGRectMake(674, 375, 350, 70);
        tutorialButton.frame = CGRectMake(674, 445, 350, 70);
        settingsButton.frame = CGRectMake(674, 515, 350, 70);
    }
    
    [backTemp addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bg];
    [self.view addSubview:backTemp];
    [self.view addSubview:quickPlayButton];
    [self.view addSubview:standardPlayButton];
    [self.view addSubview:tutorialButton];
    [self.view addSubview:settingsButton];
}


#pragma mark GCRealTimeMatchHelperDelegate method

- (void) matchStarted
{
    QuickPlayViewController *quickPlay = [[QuickPlayViewController alloc] init];
    //[[GCRealTimeMatchHelper sharedInstance] setDelegate:quickPlay];
    [self.navigationController pushViewController:quickPlay animated:YES];
}


- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) quickPlayClicked
{
    NSLog(@"quickplayclicked");
    [[GCTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 gameType:1 viewController:self];
    
    //[[GCRealTimeMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
}

- (void) standardPlayClicked
{
    NSLog(@"standardplayclicked");
    [[GCTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:3 maxPlayers:5 gameType:2 viewController:self];
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
