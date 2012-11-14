//
//  LoadingScreenViewController.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "LoadingScreenViewController.h"
#import "AppDelegate.h"
#import "StartpageViewController.h"

@interface LoadingScreenViewController ()

@end

@implementation LoadingScreenViewController

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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    bg.image = [UIImage imageNamed:@"1_load.png"];
    
    UIButton *nextScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextScreenButton addTarget:self action:@selector(nextScreenClicked) forControlEvents:UIControlEventTouchUpInside];
    nextScreenButton.frame = CGRectMake(0, 0, 480, 320);
    
    if (appDelegate.deviceType == IPAD)
    {
        bg.frame = CGRectMake(0, 0, 1024, 768);
        nextScreenButton.frame = CGRectMake(0, 0, 1024, 768);
    }
    
    [self.view addSubview: bg];
    [self.view addSubview: nextScreenButton];
}

- (void) nextScreenClicked
{
    [self.navigationController pushViewController:[[StartpageViewController alloc] init] animated:YES];
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
