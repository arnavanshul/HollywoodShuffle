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
    
    UIButton *backTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    backTemp.frame = CGRectMake(0, 0, 300, 320);
    backTemp.backgroundColor = [UIColor clearColor];
    
    UIButton *quickPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    quickPlayButton.frame = CGRectMake(305, 144, 175, 35);
    [quickPlayButton setBackgroundColor: [UIColor clearColor]];
    //[quickPlayButton setBackgroundImage:[UIImage imageNamed:@"quickplay.png"] forState:UIControlStateNormal];
    [quickPlayButton addTarget:self action:@selector(quickPlayClicked) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"%f, %f", screenWidth, screenHeight);
    
    if([[[UIDevice currentDevice] name] rangeOfString:@"iPad"].location != NSNotFound)
    {
        backTemp.frame = CGRectMake(0, 0, 512, 768);
        quickPlayButton.frame = CGRectMake(674, 305, 350, 70);
    }
    
    [backTemp addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backTemp];
    [self.view addSubview:quickPlayButton];
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
