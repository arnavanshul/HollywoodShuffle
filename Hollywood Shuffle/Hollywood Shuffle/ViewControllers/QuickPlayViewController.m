//
//  QuickPlayViewController.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "QuickPlayViewController.h"
#import "ActorObject.h"
#include <QuartzCore/QuartzCore.h>
#import "GCTurnBasedMatchHelper.h"
#import "QuickPlayMatchObject.h"
#import "PlayerObject.h"
#import "AppDelegate.h"

@interface QuickPlayViewController ()

@end

@implementation QuickPlayViewController

#define CARD_WIDTH_PHONE 64
#define CARD_HEIGHT_PHONE 90
#define REEL_WIDTH_PHONE 70
#define REEL_HEIGHT_PHONE 121
#define HAND_SCALE_FACTOR_PHONE 1.1

#define CARD_WIDTH_TAB 128
#define CARD_HEIGHT_TAB 180
#define REEL_WIDTH_TAB 140
#define REEL_HEIGHT_TAB 241
#define HAND_SCALE_FACTOR_TAB 1.1

#define INITIAL_HAND_COUNT 2

#define TIMEOUT_INTERVAL 90

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        [GCTurnBasedMatchHelper sharedInstance].delegate = self;
        
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        selectedRow = -1;
        
        if(appDelegate.deviceType == IPAD)
        {
            CARD_HEIGHT = CARD_HEIGHT_TAB;
            CARD_WIDTH = CARD_WIDTH_TAB;
            REEL_WIDTH = REEL_WIDTH_TAB;
            REEL_HEIGHT = REEL_HEIGHT_TAB;
            HAND_SCALE_FACTOR = HAND_SCALE_FACTOR_TAB;
        }else
        {
            CARD_HEIGHT = CARD_HEIGHT_PHONE;
            CARD_WIDTH = CARD_WIDTH_PHONE;
            REEL_WIDTH = REEL_WIDTH_PHONE;
            REEL_HEIGHT = REEL_HEIGHT_PHONE;
            HAND_SCALE_FACTOR = HAND_SCALE_FACTOR_PHONE;
        }
        
        cardsInHand = [[NSMutableArray alloc] init];
        cardsOnReel = [[NSMutableArray alloc] init];
        cardsPlacedThisHand = [[NSMutableArray alloc] init];
        deckCards = [[NSMutableDictionary alloc] init];
        
        cardSelected = NULL;
        
        doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGestures:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        
        handLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHandLongPressGesture:)];
        handLongPressGestureRecognizer.minimumPressDuration = 0.1;
        
        reelLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleReelLongPressGesture:)];
        reelLongPressGestureRecognizer.minimumPressDuration = 0.25;
        
        castButton = [UIButton buttonWithType:UIButtonTypeCustom];
        castButton.frame = CGRectMake(400, 223, 82, 42);
        castButton.tag = 1;
        castButton.backgroundColor = [UIColor clearColor];
        [castButton addTarget:self action:@selector(castButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *castBtnBg = [[UIImageView alloc] init];
        castBtnBg.frame = CGRectMake(0, 0, castButton.frame.size.width, castButton.frame.size.height);
        castBtnBg.image = [UIImage imageNamed:@"cast.png"];
        
        [castButton addSubview:castBtnBg];
        
        drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
        drawButton.frame = CGRectMake(400, 265, 82, 42);
        drawButton.backgroundColor = [UIColor clearColor];
        [drawButton addTarget:self action:@selector(drawButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *drawBtnBg = [[UIImageView alloc] init];
        drawBtnBg.frame = CGRectMake(0, 0, drawButton.frame.size.width, drawButton.frame.size.height);
        drawBtnBg.image = [UIImage imageNamed:@"draw.png"];
        
        [drawButton addSubview:drawBtnBg];
        
        handCardListView = [[UIScrollView alloc] init];
        handCardListView.contentSize = CGSizeMake(750, CARD_HEIGHT);
        handCardListView.backgroundColor = [UIColor clearColor];
        handCardListView.frame = CGRectMake(0, 215, 370, 100);
        [handCardListView addGestureRecognizer:handLongPressGestureRecognizer];
        handCardListView.canCancelContentTouches = NO;
        
        filmReelListView = [[UIScrollView alloc] init];
        filmReelListView.contentSize = CGSizeMake((REEL_WIDTH) * 4, REEL_HEIGHT);
        filmReelListView.backgroundColor = [UIColor clearColor];
        [filmReelListView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        filmReelListView.frame = CGRectMake(200, 95, 280, 120);
        [filmReelListView addGestureRecognizer:doubleTapGestureRecognizer];
        [filmReelListView addGestureRecognizer:reelLongPressGestureRecognizer];
        
        settingsView = [[UIView alloc] initWithFrame:CGRectMake(420, 10, 260, 310)];
        settingsView.backgroundColor = [UIColor clearColor];
        settingsShowing = false;
        
        castMovieView = [[UIView alloc] initWithFrame:CGRectMake(36, 5, 408, 120)];
        castMovieView.backgroundColor = [UIColor clearColor];
        castMovieView.hidden = true;
        //castMovieViewShowing = false;
        
        //actorNameBg = [[UIImageView alloc] initWithFrame:CGRectMake(-110, 140, 104, 46)];
        actorNameBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 135, 110, 50)];
        actorNameBg.image = [UIImage imageNamed:@"popout_name.png"];
        
        actorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 104, 45)];
        actorNameLabel.backgroundColor = [UIColor clearColor];
        actorNameLabel.textColor = [UIColor whiteColor];
        actorNameLabel.textAlignment = UITextAlignmentCenter;
        actorNameLabel.adjustsFontSizeToFitWidth = TRUE;
        actorNameLabel.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        actorNameLabel.adjustsFontSizeToFitWidth = TRUE;
        actorNameLabel.numberOfLines = 0;
        [actorNameBg addSubview:actorNameLabel];
        
        turnIndicator = [[UILabel alloc] initWithFrame: CGRectMake(35, 3, 70, 20)];
        turnIndicator.backgroundColor = [UIColor clearColor];
        turnIndicator.textColor = [UIColor yellowColor];
        turnIndicator.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        turnIndicator.adjustsFontSizeToFitWidth = YES;
        
        myPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 110, 90)];
        myPlayerView.backgroundColor = [UIColor clearColor];
        
        myPlayerImage = [[UIImageView alloc] init];
        myPlayerImage.backgroundColor = [UIColor clearColor];
        myPlayerImage.frame = CGRectMake(5, 5, 60, 60);
        
        myCardCount = [[UILabel alloc] initWithFrame:CGRectMake(45, 45, 60, 20)];
        myCardCount.backgroundColor = [UIColor clearColor];
        myCardCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        myCardCount.textColor = [UIColor whiteColor];
        myCardCount.textAlignment = UITextAlignmentRight;
        
        myPointCount = [[UILabel alloc] initWithFrame:CGRectMake(45, 68, 60, 20)];
        myPointCount.backgroundColor = [UIColor clearColor];
        myPointCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        myPointCount.textColor = [UIColor whiteColor];
        myPointCount.textAlignment = UITextAlignmentRight;
        
        [myPlayerView addSubview: myCardCount];
        [myPlayerView addSubview: myPointCount];
        [myPlayerView addSubview: myPlayerImage];
        
        otherPlayerView = [[UIView alloc] initWithFrame:CGRectMake(145, 0, 150, 90)];
        otherPlayerView.backgroundColor = [UIColor clearColor];
        
        otherPlayerImage = [[UIImageView alloc] init];
        otherPlayerImage.backgroundColor = [UIColor clearColor];
        otherPlayerImage.frame = CGRectMake(5, 5, 60, 60);
        
        otherCardCount = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 60, 20)];
        otherCardCount.backgroundColor = [UIColor clearColor];
        otherCardCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        otherCardCount.textColor = [UIColor whiteColor];
        otherCardCount.textAlignment = UITextAlignmentRight;
        
        otherPointCount = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 60, 20)];
        otherPointCount.backgroundColor = [UIColor clearColor];
        otherPointCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
        otherPointCount.textColor = [UIColor whiteColor];
        otherPointCount.textAlignment = UITextAlignmentRight;
        
        [otherPlayerView addSubview: otherCardCount];
        [otherPlayerView addSubview: otherPointCount];
        [otherPlayerView addSubview: otherPlayerImage];
        
        if(appDelegate.deviceType == IPAD)
        {
            castButton.frame = CGRectMake(850, 119, 180, 60);
            castBtnBg.frame = CGRectMake(0, 0, castButton.frame.size.width, castButton.frame.size.height);
            drawButton.frame = CGRectMake(850, 180, 180, 60);
            drawBtnBg.frame = CGRectMake(0, 0, drawButton.frame.size.width, drawButton.frame.size.height);
            
            handCardListView.frame = CGRectMake(0, 538, 1024, 200);
            filmReelListView.frame = CGRectMake(353, 270, 500, 240);
            //settingsView.frame = CGRectMake(950, 10, 260, 310);
            settingsView.frame = CGRectMake(965, 10, 260, 310);
            castMovieView.frame = CGRectMake(100, 10, 816, 240);
            actorNameBg.frame = CGRectMake(0, 330, 220, 120);
            actorNameLabel.frame = CGRectMake(5, 5, 210, 110);
            actorNameLabel.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
            turnIndicator.frame = CGRectMake(70, 6, 140, 40);
            turnIndicator.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
            
            myPlayerView.frame = CGRectMake(10, 50, 180, 180);
            myPlayerView.backgroundColor = [UIColor clearColor];
            myPlayerImage.frame = CGRectMake(5, 5, 75, 75);
            myCardCount.frame = CGRectMake(75, 90, 100, 30);
            myCardCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
            myPointCount.frame = CGRectMake(75, 125, 100, 30);
            myPointCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
            
            otherPlayerView.frame = CGRectMake(350, 10, 180, 180);
            otherPlayerView.backgroundColor = [UIColor clearColor];
            otherPlayerImage.frame = CGRectMake(5, 5, 75, 75);
            otherCardCount.frame = CGRectMake(75, 10, 100, 30);
            otherCardCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
            otherPointCount.frame = CGRectMake(75, 45, 100, 30);
            otherPointCount.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:25];
        }
        
        [self layoutSettingsView];
        [self layoutCastMovieView];
    }
    
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UIImageView *deckStack = [[UIImageView alloc] initWithFrame:CGRectMake(139, 110, 64, 93)];
    deckStack.image = [UIImage imageNamed:@"deck_stack.png"];
    
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.frame = CGRectMake(0, 0, 480, 320);
    bgView.image = [UIImage imageNamed:@"bg.png"];
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    NSArray *participants = [currentMatch participants];
    NSMutableArray *playerIds = [[NSMutableArray alloc] init];
    
    for (GKTurnBasedParticipant *participant in participants)
    {
        if (participant.playerID)
        {
            [playerIds addObject: participant.playerID];
        }
    }
    
    [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@: %@", error, [error description]);
             
         }else
         {
             for (GKPlayer *player in players)
             {
                 [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error)
                 {
                     if (photo)
                     {
                         if([player.playerID isEqualToString:[[GKLocalPlayer localPlayer] playerID]])
                         {
                             myPlayerImage.image = photo;
                             otherPlayerImage.image = photo;
                         }else
                         {
                             otherPlayerImage.image = photo;
                             myPlayerImage.image = photo;
                         }
                     }
                 }];
             }
         }
     }];
    
    //if([[[UIDevice currentDevice] name] isEqualToString:@"iPad Simulator"])
    if (appDelegate.deviceType == IPAD)
    {
        //CGRect screenRect = [[UIScreen mainScreen] bounds];
        bgView.frame = CGRectMake(0, 0, 1024, 768);
        deckStack.frame = CGRectMake(230, 300, 128, 186);
        //bgView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        //castButton.frame = CGRectMake(800, 450, 250, 50);
        //drawButton.frame = CGRectMake(800, 520, 250, 50);
        //handCardListView.frame = CGRectMake(180, 420, 580, 220);
        
        //handCardListView.backgroundColor = [UIColor redColor];
        //filmReelListView.backgroundColor = [UIColor blueColor];
    }
    
    [self.view addSubview: bgView];
    [self.view addSubview: deckStack];
    [self.view addSubview: filmReelListView];
    [self.view addSubview: handCardListView];
    [self.view addSubview: settingsView];
    [self.view addSubview: castMovieView];
    [self.view addSubview: castButton];
    [self.view addSubview: drawButton];
    [self.view addSubview: actorNameBg];
    [self.view addSubview: turnIndicator];
    [self.view addSubview: myPlayerView];
    [self.view addSubview: otherPlayerView];
    
    [self layoutHand];
}


- (void) viewDidAppear:(BOOL)animated
{
    /*
    actorNameBg.frame = CGRectMake(0, 140, 110, 40);
    [actorNameBg setHidden: FALSE];
     */
    /*
    NSLog(@"%d", [appDelegate connectedToInternet]);
    
    if(![appDelegate connectedToInternet])
    {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"NOT CONNECTED TO INTERNET" message:@"You have to be connected to internet to play this game!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noInternet show];
    }
    */
}



- (void) layoutSettingsView
{
    settingsBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 310)];
    settingsBg.image = [UIImage imageNamed:@"bg_border_andgear.png"];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(0, 0, 60, 60);
    
    /*
    UIButton *volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeButton.frame = CGRectMake(142, 15, 40, 30);
    [volumeButton setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
    [volumeButton addTarget:self action:@selector(volumeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    */
    
    UIButton *helpButton = [UIButton buttonWithType: UIButtonTypeCustom];
    helpButton.frame = CGRectMake(95, 75, 142, 40);
    [helpButton setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(helpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    UIButton *settings2Button = [UIButton buttonWithType: UIButtonTypeCustom];
    settings2Button.frame = CGRectMake(95, 117, 142, 40);
    [settings2Button setBackgroundImage:[UIImage imageNamed:@"settings2.png"] forState:UIControlStateNormal];
    [settings2Button addTarget:self action:@selector(settings2ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    */
    
    UIButton *exitButton = [UIButton buttonWithType: UIButtonTypeCustom]; //exit to menu
    //exitButton.frame = CGRectMake(95, 159, 142, 40);
    exitButton.frame = CGRectMake(95, 139, 142, 40);
    [exitButton setBackgroundImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *quitButton = [UIButton buttonWithType: UIButtonTypeCustom]; // quits game
    quitButton.frame = CGRectMake(95, 201, 142, 40);
    [quitButton setBackgroundImage:[UIImage imageNamed:@"quit-game.png"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    UIImageView *frndsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(95, 245, 142, 40)];
    frndsOnline.image = [UIImage imageNamed:@"friends.png"];
    */
    
    if (appDelegate.deviceType == IPAD)
    {
        /*
        settingsBg.frame = CGRectMake(0, 0, 0, 0);
        settingsButton.frame = CGRectMake(0, 0, 0, 0);
        volumeButton.frame = CGRectMake(0, 0, 0, 0);
        helpButton.frame = CGRectMake(0, 0, 0, 0);
        settingsButton.frame = CGRectMake(0, 0, 0, 0);
        exitButton.frame = CGRectMake(0, 0, 0, 0);
        quitButton.frame = CGRectMake(0, 0, 0, 0);
        frndsOnline.frame = CGRectMake(0, 0, 0, 0);
         */
    }
    
    [settingsView addSubview: settingsBg];
    [settingsView addSubview: settingsButton];
    //[settingsView addSubview: volumeButton];
    [settingsView addSubview: helpButton];
    //[settingsView addSubview: settings2Button];
    [settingsView addSubview: exitButton];
    [settingsView addSubview: quitButton];
    //[settingsView addSubview: frndsOnline];
}


- (void) layoutCastMovieView
{
    UIImageView *castMovieBg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"cast_bg.png"]];
    castMovieBg.frame = CGRectMake(0, 0, castMovieView.frame.size.width, castMovieView.frame.size.height);
    
    UIButton *hideCastMovieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hideCastMovieBtn.frame = CGRectMake(370, 10, 25, 25);
    [hideCastMovieBtn addTarget:self action:@selector(hideCastMovieBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [hideCastMovieBtn setBackgroundImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
    
    UIButton *confirmCastMovieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmCastMovieBtn.frame = CGRectMake(300, 63, 102, 37);
    confirmCastMovieBtn.tag = 2;
    [confirmCastMovieBtn addTarget:self action:@selector(castButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [confirmCastMovieBtn setBackgroundImage:[UIImage imageNamed:@"cast_movie.png"] forState:UIControlStateNormal];
    
    movieName = [[UITextField alloc] initWithFrame: CGRectMake(22, 70, 250, 30)];
    
    if (appDelegate.deviceType == IPAD)
    {
        castMovieBg.frame = CGRectMake(0, 0, castMovieView.frame.size.width, castMovieView.frame.size.height);
        hideCastMovieBtn.frame = CGRectMake(750, 15, 40, 40);
        confirmCastMovieBtn.frame = CGRectMake(600, 130, 200, 70);
        movieName.frame = CGRectMake(45, 140, 500, 50);
        movieName.font = [UIFont systemFontOfSize: 35];
    }
    
    [castMovieView addSubview: castMovieBg];
    [castMovieView addSubview: hideCastMovieBtn];
    [castMovieView addSubview: confirmCastMovieBtn];
    [castMovieView addSubview: movieName];
}

- (void) layoutHand
{
    //EMPTYING THE HAND SCROLLVIEW
    for (UIView *view in [handCardListView subviews])
    {
        [view removeFromSuperview];
    }
    
    //ADDING IMAGES TO HAND
    float tempWidth = (CARD_WIDTH * HAND_SCALE_FACTOR);
    for (int i = 0; i < [cardsInHand count]; i++)
    {
        ActorObject *temp = [cardsInHand objectAtIndex: i];
        UIImageView *view = temp.actorImageView;
        view.frame = CGRectMake(i * tempWidth, 0, tempWidth, CARD_HEIGHT * HAND_SCALE_FACTOR);
        [handCardListView addSubview: view];
        view.layer.borderColor = [UIColor blackColor].CGColor;
    }

    handCardListView.contentSize = CGSizeMake(([cardsInHand count]) * tempWidth, CARD_HEIGHT);
    NSLog(@"%d", [cardsInHand count]);
    NSLog(@"%.2f", handCardListView.contentSize.width);
    
    //EMPTYING THE REEL SCROLLVIEW
    for (UIView *view in [filmReelListView subviews])
    {
        [view removeFromSuperview];
    }
    
    //ADDING IMAGES TO REEL
    filmReelListView.contentSize = CGSizeMake(([cardsOnReel count] + 1) * REEL_WIDTH, CARD_HEIGHT);
    
    int x = 0;
    int xPosition = (REEL_WIDTH - CARD_WIDTH)/2;
    int yPosition = (REEL_HEIGHT - CARD_HEIGHT)/2;
    
    for (int i = 0; i < [cardsOnReel count]; i++)
    {
        ActorObject *temp = [cardsOnReel objectAtIndex: i];
        
        UIImageView *cardBg = [[UIImageView alloc] initWithFrame:CGRectMake(x, -1, REEL_WIDTH, REEL_HEIGHT)];
        cardBg.backgroundColor = [UIColor clearColor];
        cardBg.image = [UIImage imageNamed:@"reel_1.png"];
        
        UIImageView *cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition - 1, yPosition, CARD_WIDTH + 1, CARD_HEIGHT)];
        cardImage.image = temp.actorImageView.image;
        cardImage.layer.cornerRadius = 5;
        cardImage.layer.masksToBounds = YES;
        cardImage.layer.borderWidth = 1.0f;
        cardImage.layer.borderColor = [UIColor clearColor].CGColor;
        
        [cardBg addSubview:cardImage];
        [filmReelListView addSubview: cardBg];
        
        x = x + REEL_WIDTH;
    }
    
    
    /*
     ****************************************************************************************************************************************************
     
     THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE MULTIPLE CARDS IN A SINGLE TURN
     
     ****************************************************************************************************************************************************
     
    UIImageView *crossReelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_reel_03.png"]];
    crossReelImage.frame = CGRectMake(x, 0, 70, 120);
    [filmReelListView addSubview: crossReelImage];
    
    if ((x - 0) >= filmReelListView.frame.size.width)
    {
        [filmReelListView setContentOffset:CGPointMake(x - (70 * 3), 0) animated:YES];
    }
     */
    
    
    /*
     ****************************************************************************************************************************************************
     
     THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE SINGLE CARD EVERY TURN
     
     ****************************************************************************************************************************************************
     */
    if ([cardsOnReel count] == 1)
    {
        UIImageView *crossReelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_reel_03.png"]];
        crossReelImage.frame = CGRectMake(x, 0, REEL_WIDTH, REEL_HEIGHT);
        [filmReelListView addSubview: crossReelImage];
        castButton.enabled = false;
    }else
    {
        castButton.enabled = true;
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------------
    
}


- (void) handleDoubleTapGestures: (UITapGestureRecognizer *) sender
{
    if ([cardsOnReel count] > 1)
    {
        CGPoint doubleTapLocation = [sender locationInView:filmReelListView];
        
        selectedCardNum = doubleTapLocation.x/(REEL_WIDTH);
        
        //create an array for the cards placed on the reel in this hand. the below logic is executed if
        //cardaddedtoreel is an object from that array...
        
        if(selectedCardNum < [cardsOnReel count])
        {
            cardAddedToReel = [cardsOnReel objectAtIndex:selectedCardNum];
            
            if ([cardsPlacedThisHand containsObject:cardAddedToReel])
            {
                [cardsOnReel removeObjectAtIndex:selectedCardNum];
                [cardsPlacedThisHand removeObjectAtIndex:[cardsPlacedThisHand indexOfObject:cardAddedToReel]];
                [cardsInHand addObject:cardAddedToReel];
                [self layoutHand];
            }else
            {
                UIAlertView *ignoreDoubleTap = [[UIAlertView alloc] initWithTitle:@"Only cards placed this hand can be removed!!!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [ignoreDoubleTap show];
            }
            
            selectedCardNum = -1;
        }
    }
}

- (void) handleHandLongPressGesture: (UILongPressGestureRecognizer *) sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"");
            
            CGPoint longPressLocation = [sender locationInView:handCardListView];
            CGPoint locationOnScreen = [sender locationInView:self.view];
            selectedCardNum = longPressLocation.x/(CARD_WIDTH * HAND_SCALE_FACTOR);
            NSLog(@"selected card is = %d", selectedCardNum);
            if (selectedCardNum < [cardsInHand count])
            {
                cardSelectedFromHand = [cardsInHand objectAtIndex:selectedCardNum];
                
                cardSelected = [cardSelectedFromHand copy];
                cardSelected.actorImageView.frame = cardSelectedFromHand.actorImageView.frame;
                
                cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
                cardSelected.actorImageView.center = locationOnScreen;
                cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - CARD_HEIGHT/2);
                cardSelected.actorImageView.layer.borderColor = [UIColor clearColor].CGColor;
                actorNameLabel.text = cardSelected.actorName;
                //[self animateShowName];
                [self.view addSubview:cardSelected.actorImageView];
            }
            
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateChanged:
            if(cardSelected)
            {
                cardSelected.actorImageView.alpha = 0.7;
                cardSelected.actorImageView.center = [sender locationInView:self.view];
            }
            
            break;
        case UIGestureRecognizerStateEnded:
            
            NSLog(@"%f", filmReelListView.frame.size.height);
            CGPoint temp = [sender locationInView:filmReelListView];
                        
            if (temp.y > 0 && temp.y < filmReelListView.frame.size.height && temp.x > 0 && [[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:
                                                                                            [[GCTurnBasedMatchHelper sharedInstance] currentMatch]])
            {
                cardSelected.actorImageView.alpha = 1;
                
                ActorObject *tempObj = [cardSelected copy];                      //The card to be added on to the reel
                
                /*
                 ********************************************************************************************************************************************
                 
                 THE BELOW CODE WAS USED TO PLACE THE LAST REEL IMAGE WITH THE PLUS SIGN IF AND WHEN THE USERS WERE ALLOWED TO PLACE MORE THAN ONE CARD EVERY TURN
                 
                 ********************************************************************************************************************************************
                
                [cardsOnReel addObject:tempObj];
                [cardsPlacedThisHand addObject:tempObj];
                [cardsInHand removeObjectAtIndex:selectedCardNum];
                
                //---------------------------------------------------------------------------------------------------------------------------------------------
                 */
                
                /*
                 *********************************************************************************************************************************************
                 
                 THE BELOW CODE CONFORMS TO THE PLAYING DIRECTIONS WHERE ONLY ONE CARD CAN BE PLAYED EACH HAND. IT REPLACES THE CARD ON THE FILM REEL WITH THE CURRENT CARD SELECTION
                 
                 *********************************************************************************************************************************************
                */
                if ([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:[[GCTurnBasedMatchHelper sharedInstance] currentMatch]])
                {
                    if([cardsOnReel count] > 1)
                    {
                        ActorObject *tempObj2 = [cardsOnReel objectAtIndex:([cardsOnReel count] - 1)];
                        [cardsOnReel replaceObjectAtIndex:([cardsOnReel count] - 1) withObject:tempObj];
                        [cardsPlacedThisHand replaceObjectAtIndex:([cardsPlacedThisHand count] - 1) withObject:tempObj];//Not really needed in this implementation
                        [cardsInHand addObject: tempObj2];
                    }else
                    {
                        [cardsOnReel addObject: tempObj];
                        [cardsPlacedThisHand addObject: tempObj];//Not really needed in this implementation
                    }
                }
                
                [cardsInHand removeObjectAtIndex: selectedCardNum];
                
                //---------------------------------------------------------------------------------------------------------------------------------------------
                
                [self layoutHand];
            }
            
            //[self performSelector:@selector(animateHideName) withObject:nil afterDelay:0.5];
            
            [cardSelected.actorImageView removeFromSuperview];
            cardSelected = NULL;
            
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"gesture state failed");
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"gesture state possible");
            break;
            
        default:
            break;
    }
}

- (void) handleReelLongPressGesture: (UILongPressGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint longPressLocation = [sender locationInView:filmReelListView];
        CGPoint locationOnScreen = [sender locationInView:self.view];
        selectedCardNum = longPressLocation.x/(REEL_WIDTH);
        NSLog(@"the selected card = %d", selectedCardNum);
        NSLog(@"card count on reel = %d", [cardsOnReel count]);
        if(selectedCardNum < [cardsOnReel count])
        {
            ActorObject *cardSelectedOnReel = [cardsOnReel objectAtIndex:selectedCardNum];
            
            cardSelected = [cardSelectedOnReel copy];
            cardSelected.actorImageView.frame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
            cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
            cardSelected.actorImageView.center = locationOnScreen;
            cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - CARD_HEIGHT/2);
            cardSelected.actorImageView.layer.borderColor = [UIColor clearColor].CGColor;
            actorNameLabel.text = cardSelected.actorName;
            //[self animateShowName];
            [self.view addSubview:cardSelected.actorImageView];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateEnded)
    {
        [cardSelected.actorImageView removeFromSuperview];
        NSLog(@"reel long press now failed");
        
        //[self performSelector:@selector(animateHideName) withObject:nil afterDelay:0.25];
        
        cardSelected = NULL;
        selectedCardNum = -1;
    }
}

- (void) castButtonClicked: (UIButton *)sender
{
    if(sender.tag == 2)
    {
        NSInteger id1, id2;
        id1 = [[cardsOnReel objectAtIndex:0] actorId];
        id2 = [[cardsOnReel objectAtIndex:1] actorId];
        
        if([self validateMovieTitle:movieName.text withActor1:id1 andActor2:id2])
        {
            [cardsPlacedThisHand removeAllObjects];
            
            for (int i = 0; i < [cardsOnReel count] - 1; i++)
            {
                [cardsOnReel removeObjectAtIndex: i];
            }
            
            ActorObject *temp = [cardsOnReel objectAtIndex:0];
            
            currentMatchObj.lastActorCast = temp.actorId;
            currentMatchObj.deckCardList = deckCards;
            [currentMatchObj.lastMovieCast setString:movieName.text];
            
            //Preserving the order of the cards in hand
            [myPlayer.playerCardList removeAllObjects];
            
            for (ActorObject *temp in cardsInHand)
            {
                [myPlayer.playerCardList addObject:[NSNumber numberWithInteger:temp.actorId]];
            }
            
            GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
            
            GKTurnBasedParticipant *nextParticipant;
            NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
            nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count ])];
            
            if([myPlayer.playerCardList count] > 0) // if the current player still has cards, the game continues
            {
                NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                                   [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
                
                if([currentMatch respondsToSelector:@selector(endTurnWithNextParticipants:turnTimeout:matchData:completionHandler:)])
                {
                    [currentMatch endTurnWithNextParticipants:[NSArray arrayWithObject:nextParticipant] turnTimeout:TIMEOUT_INTERVAL matchData:currentMatchData completionHandler:^(NSError *error) {
                        if (error)
                        {
                            NSLog(@"%@", error);
                        }
                    }];
                }else
                {
                    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:currentMatchData completionHandler:^(NSError *error)
                     {
                         if (error)
                         {
                             NSLog(@"%@", error);
                         }
                     }];
                }
                
                turnIndicator.text = @"Opponent's Turn";
                
            }else // else the current player wins the game.
            {
                for(GKTurnBasedParticipant *participant in currentMatch.participants)
                {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                }
                
                currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                
                myPlayer.playerStatus = PLAYER_WON;
                
                
                NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                                   [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
                
                GKTurnBasedMatch *match = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
                
                for (GKTurnBasedParticipant *participant in match.participants)
                {
                    NSLog(@"%@ = %d", participant.playerID, participant.status);
                }
                
                [currentMatch endMatchInTurnWithMatchData:currentMatchData completionHandler:^(NSError *error)
                {
                    if (error)
                    {
                        NSLog(@"%@", error);
                    }
                }];
                
                turnIndicator.text = @"Match Ended";
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"You Won!!!" delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
                av.tag = 1;
                [av show];
            }
            
            actorNameLabel.text = movieName.text;
            
            myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
            myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
            
            otherCardCount.text = [NSString stringWithFormat:@"%d cards", [otherPlayer.playerCardList count]];
            otherPointCount.text = [NSString stringWithFormat:@"%d points", otherPlayer.playerPoints];
            
        }
        
        [self layoutHand];
        
        [self hideCastMovieBtnClicked];
        
        [movieName resignFirstResponder];
        
    }else if (sender.tag == 1)
    {
        [movieName becomeFirstResponder];
        
        castMovieView.hidden = false;
        [self.view bringSubviewToFront:castMovieView];
    }
}

- (void) hideCastMovieBtnClicked
{
    castMovieView.hidden = true;
    [movieName resignFirstResponder];
    [movieName setText:@""];
}

- (void) drawButtonClicked
{
    //draw button click event definition
    
    for (ActorObject *temp in cardsPlacedThisHand)
    {
        [cardsInHand addObject:temp];
    }
    
    for (int i = 1; i < [cardsOnReel count]; i++)
    {
        [cardsOnReel removeObjectAtIndex:i];
    }
    
    [cardsPlacedThisHand removeAllObjects];
    
    if ([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:[[GCTurnBasedMatchHelper sharedInstance] currentMatch]])
    {
        if(castMovieView.hidden)
        {
            ActorObject *temp = nil;
            
            if([deckCards count] == 0)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"Deck empty..."
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }else
            {
                while (!temp)
                {
                    int value = (arc4random() % 54) + 101;
                    
                    if ([deckCards objectForKey:[NSNumber numberWithInt:value]])
                    {
                        temp = [appDelegate.all52Cards objectForKey:[NSNumber numberWithInt:value]];
                        [deckCards removeObjectForKey:[NSNumber numberWithInt:value]];
                        [myPlayer.playerCardList addObject:[NSNumber numberWithInt:value]];
                        [cardsInHand addObject:[appDelegate.all52Cards objectForKey:[NSNumber numberWithInt:value]]];
                    }
                }
                
                currentMatchObj.deckCardList = deckCards;
                
                //Preserving the order of the cards in hand
                [myPlayer.playerCardList removeAllObjects];
                
                for (ActorObject *temp in cardsInHand)
                {
                    [myPlayer.playerCardList addObject:[NSNumber numberWithInteger:temp.actorId]];
                }
                
                [self layoutHand];
                
                NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                                   [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
                
                GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
                
                GKTurnBasedParticipant *nextParticipant;
                NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
                nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count ])];
                
                if([currentMatch respondsToSelector:@selector(endTurnWithNextParticipants:turnTimeout:matchData:completionHandler:)])
                {
                    [currentMatch endTurnWithNextParticipants:[NSArray arrayWithObject:nextParticipant] turnTimeout:60 matchData:currentMatchData
                                            completionHandler:^(NSError *error) {
                                                if (error)
                                                {
                                                    NSLog(@"%@", error);
                                                }
                                            }];
                }else
                {
                    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:currentMatchData completionHandler:^(NSError *error)
                     {
                         if (error)
                         {
                             NSLog(@"%@", error);
                         }
                     }];
                }
                
                turnIndicator.text = @"Opponent's Turn";
                
                myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
            }
        }
    }
}

- (void) settingsClicked
{
    [UIView beginAnimations:@"startSettingsAnimation" context:NULL];
    [UIView setAnimationDuration:0.25];
    
    if(settingsShowing)
    {
        settingsView.center = CGPointMake(settingsView.center.x + 200, settingsView.center.y);
        settingsBg.image = [UIImage imageNamed:@"bg_border_andgear.png"];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector:@selector(settingsHidden)];
        settingsShowing = false;
    }else
    {
        settingsView.center = CGPointMake(settingsView.center.x - 200, settingsView.center.y);
        settingsBg.image = [UIImage imageNamed:@"whole_settings_show_all.png"];
        [self.view bringSubviewToFront: settingsView];
        settingsShowing = true;
    }
    
    [UIView commitAnimations];
}

- (void) settingsHidden
{
    [self.view bringSubviewToFront: castButton];
    [self.view bringSubviewToFront: drawButton];
}

- (void) volumeButtonClicked
{
    
}

- (void) helpButtonClicked
{
    
}

- (void) settings2ButtonClicked
{
    
}

- (void) exitButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) quitButtonClicked
{
    if([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch: [[GCTurnBasedMatchHelper sharedInstance] currentMatch]])
    {
        myPlayer.playerStatus = PLAYER_QUIT;
        GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
        
        [currentMatch.currentParticipant setMatchOutcome:GKTurnBasedMatchOutcomeQuit];
        
        NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                           [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
        
        GKTurnBasedParticipant *nextParticipant;
        NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];
        
        
        //Set the match outcome for all the participants...
        for(GKTurnBasedParticipant *participant in currentMatch.participants)
        {
            participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
        }
        
        currentMatch.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeLost;
        
        [currentMatch endMatchInTurnWithMatchData:currentMatchData completionHandler:^(NSError *error)
         {
             if (error)
             {
                 NSLog(@"completion handler %@", error);
             }
             
             [currentMatch removeWithCompletionHandler:^(NSError *error)
              {
                  NSLog(@"%@", error);
                  
                  [self.navigationController popViewControllerAnimated:YES];
              }];
         }];
        
    }else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"You can only quit if it is your turn"
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void) animateShowName
{
    [actorNameBg.layer removeAllAnimations];
    [UIView beginAnimations:@"startNameAnimation" context:NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration:0.25];
    actorNameBg.frame = CGRectMake(0, 140, 110, 40);
    [UIView commitAnimations];
}

- (void) animateHideName
{
    [actorNameBg.layer removeAllAnimations];
    [UIView beginAnimations:@"startNameAnimation" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.25];
    actorNameBg.frame = CGRectMake(-110, 140, 110, 40);
    [UIView commitAnimations];
}

- (BOOL) validateMovieTitle:(NSString *)title withActor1:(NSInteger)actorId1 andActor2:(NSInteger)actorId2
{
    NSLog(@"%@, %d, %d", title, actorId1, actorId2);
    return true;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str setString: [NSString stringWithFormat:
                     @"http://tblr.asu.edu/hollywoodshuffle/hsmovie.php?movie_title=%@&actorId1=%d&actorId2=%d", title, actorId1, actorId2]];
    NSLog(@"urlstring = %@", str);
    
    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] ;
    NSLog(@"url = %@", url);
    
    NSString *result = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSLog(@"result = %@", result);
    
    if ([result integerValue] == 1)
    {
        // everything good
        
        myPlayer.playerPoints += 1000;
        
        return TRUE;
        
    }else if ([result integerValue] == 0)
    {
        // movie does not exist
        //myPlayer.playerPoints -= 250;
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"Movie not found in the database..."
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
        
    }else if ([result integerValue] == -2)
    {
        // incorrect movie cast (actors not matched)
        
        myPlayer.playerPoints -= 250;
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"Actors not matched!!!"
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
        
    }else if ([result integerValue] == -1)
    {
        // incorrect movie cast (actors not matched)
        //myPlayer.playerPoints -= 250;
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"Movie not found in the database..."
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        
        myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
    }
    return FALSE;
}


#pragma mark GCRealTimeMatchDelegate

- (void)matchEnded
{
    NSLog(@"Match ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSLog(@"Received data");
}



#pragma mark GCTurnBasedMatchHelperDelegate

-(void)enterNewGame:(GKTurnBasedMatch *)match
{
    // for the player starting the match
    
    NSLog(@"Start new game (logged in view controller)...");
    
    // allocate cards to the players
    // set the initial base card
    // setup the current match object
    // setup cardsInHand and cardsOnReel objects
    // layout the hand
    
    currentMatchObj = [[QuickPlayMatchObject alloc] init];
    
    //for (int i=0; i < [appDelegate.all52Cards count]; i++) //FOR TEST PURPOSES
    for (int i = 101; i <= 153; i++)
    {
        [deckCards setObject:[NSNumber numberWithInteger:i] forKey:[NSNumber numberWithInteger:i]];
    }
    
    while ([cardsInHand count] < INITIAL_HAND_COUNT)
    {
        int value = (arc4random() % 54) + 101;
        NSLog(@"%d", value);
        if ([deckCards objectForKey:[NSNumber numberWithInt:value]])
        {
            [cardsInHand addObject:[appDelegate.all52Cards objectForKey:[NSNumber numberWithInt:value]]];
            [deckCards removeObjectForKey:[NSNumber numberWithInt:value]];
        }
    }
    
    while ([cardsOnReel count] < 1)
    {
        int value = (arc4random() % 54) + 101;
        
        if ([deckCards objectForKey:[NSNumber numberWithInt:value]])
        {
            [cardsOnReel addObject: [appDelegate.all52Cards objectForKey:[NSNumber numberWithInt:value]]];
            [deckCards removeObjectForKey:[NSNumber numberWithInt:value]];
            currentMatchObj.lastActorCast = value;
        }
    }
    
    myPlayer = [[PlayerObject alloc] init];
    
    [myPlayer.playerId setString:[match.currentParticipant playerID]];
    
    for (ActorObject *card in cardsInHand)
    {
        [myPlayer.playerCardList addObject:[NSNumber numberWithInteger:card.actorId]];
    }
    
    myPlayer.playerPoints = 0;
    
    [currentMatchObj.playersList setObject:myPlayer forKey:myPlayer.playerId];
    currentMatchObj.deckCardList = deckCards;
    
    // SETTING UP THE REST OF THE VIEW
    
    actorNameLabel.text = currentMatchObj.lastMovieCast;
    
    myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
    myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
    
    otherCardCount.text = [NSString stringWithFormat:@"%d cards", [otherPlayer.playerCardList count]];
    otherPointCount.text = [NSString stringWithFormat:@"%d points", otherPlayer.playerPoints];
    
    [self layoutHand];
}


-(void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Entering existing game (logged in view controller)...");
    
    currentMatchObj = [NSKeyedUnarchiver unarchiveObjectWithData: match.matchData];
    
    deckCards = currentMatchObj.deckCardList;
    
    if (![currentMatchObj.playersList objectForKey:[[GKLocalPlayer localPlayer] playerID]]) // joining player's first turn
    {
        while ([cardsInHand count] < INITIAL_HAND_COUNT)
        {
            int value = (arc4random() % 54) + 101;
            if ([deckCards objectForKey:[NSNumber numberWithInt:value]])
            {
                [cardsInHand addObject:[appDelegate.all52Cards objectForKey:[NSNumber numberWithInt:value]]];
                [deckCards removeObjectForKey:[NSNumber numberWithInt:value]];
            }
        }
        
        myPlayer = [[PlayerObject alloc] init];
        
        [myPlayer.playerId setString:[match.currentParticipant playerID]];
        myPlayer.playerCardList = [[NSMutableArray alloc] init];
        
        for (ActorObject *card in cardsInHand)
        {
            [myPlayer.playerCardList addObject:[NSNumber numberWithInteger:card.actorId]];
        }
        
        myPlayer.playerPoints = 0;
        
        [currentMatchObj.playersList setObject:myPlayer forKey:myPlayer.playerId];
        
        NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                           [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
        
        if([match respondsToSelector:@selector(endTurnWithNextParticipants:turnTimeout:matchData:completionHandler:)])
        {
            [match endTurnWithNextParticipants:[NSArray arrayWithObject:match.currentParticipant] turnTimeout:TIMEOUT_INTERVAL matchData:currentMatchData completionHandler:^(NSError *error) {
                if (error)
                {
                    NSLog(@"%@", error);
                }
            }];
        }else
        {
            [match endTurnWithNextParticipant:match.currentParticipant matchData:currentMatchData completionHandler:^(NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"%@", error);
                 }
             }];
        }
        
    }else //other player either quit from outside the viewcontroller or took his turn
    {
        for (GKTurnBasedParticipant *participant in match.participants)
        {
            //obtaining game data
            if ([participant.playerID isEqualToString:[[GKLocalPlayer localPlayer] playerID]])
            {
                myPlayer = [currentMatchObj.playersList objectForKey:participant.playerID];
            }else
            {
                otherPlayer = [currentMatchObj.playersList objectForKey:participant.playerID];
            }

            //check if the other participant quit outside the viewcontroller (could be scaled to any number of participants)
            if(participant.matchOutcome == GKTurnBasedMatchOutcomeQuit)
            {
                [[currentMatchObj.playersList objectForKey:participant.playerID] setPlayerStatus:PLAYER_QUIT];
                
                match.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                
                NSData *currentMatchData = [NSKeyedArchiver archivedDataWithRootObject: currentMatchObj];
                
                [match endMatchInTurnWithMatchData:currentMatchData completionHandler:^(NSError *error)
                 {
                     NSLog(@"%@", error);
                     if (error)
                     {
                         NSLog(@"%@", error);
                     }
                     
                     [self layoutMatch: match];
                }];
            }
        }
        
        [cardsInHand removeAllObjects];
        
        for (NSNumber *tempActorId in myPlayer.playerCardList) //adding actor objects to cardsInHand
        {
            [cardsInHand addObject:[appDelegate.all52Cards objectForKey:tempActorId]];
        }
        
        if (match.status == GKTurnBasedMatchStatusOpen)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"Your Turn..."
                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
    
    [cardsOnReel removeAllObjects];
    [cardsOnReel addObject:[appDelegate.all52Cards objectForKey:[NSNumber numberWithInteger: currentMatchObj.lastActorCast]]];
    
    // Not needed here but could be of use if more than two players are playing
    
    if([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:match])
    {
        castButton.enabled = true;
        drawButton.enabled = true;
    }else
    {
        castButton.enabled = false;
        drawButton.enabled = false;
    }
    
    [self layoutMatch: match];
}


-(void)layoutMatch:(GKTurnBasedMatch *)match
{
    if (![match.currentParticipant.playerID isEqualToString:[[GKLocalPlayer localPlayer] playerID]]) // if this is not our turn and the method is called directly, gather game data from match object
    {
        currentMatchObj = [NSKeyedUnarchiver unarchiveObjectWithData: match.matchData];
        
        myPlayer = [currentMatchObj.playersList objectForKey:[[GKLocalPlayer localPlayer] playerID]];
        
        for (NSString *playerId in [currentMatchObj.playersList allKeys])
        {
            if (![playerId isEqualToString: myPlayer.playerId])
            {
                otherPlayer = [currentMatchObj.playersList objectForKey:playerId];
            }
        }
        
        [cardsInHand removeAllObjects];
        for (NSNumber *key in myPlayer.playerCardList)
        {
            [cardsInHand addObject: [appDelegate.all52Cards objectForKey:key]];
        }
        
        [cardsOnReel removeAllObjects];
        [cardsOnReel addObject: [appDelegate.all52Cards objectForKey: [NSNumber numberWithInteger:currentMatchObj.lastActorCast]]];
    }
    
    if (match.status == GKTurnBasedMatchStatusEnded)
    {
        if (otherPlayer.playerStatus == PLAYER_QUIT)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"The other player quit. You are the winner..."
                                                        delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
            av.tag = 1;
            [av show];
            
            if (match.status != GKTurnBasedMatchStatusEnded) //other player quit out of turn
            {
                myPlayer.playerStatus = PLAYER_WON;
                
                match.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                
                NSData *currentMatchData = [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj];
                
                [match endMatchInTurnWithMatchData: currentMatchData completionHandler:^(NSError *error) {
                    if (error)
                    {
                        NSLog(@"error ending match: %@", error);
                    }else
                    {
                        [match removeWithCompletionHandler:^(NSError *error)
                         {
                             if(error)
                             {
                                 NSLog(@"error removing match: %@", error);
                             }
                         }];
                    }
                }];
                
            }
        }else //called from receiveEndGame (the other player has won or quit in turn from inside the viewcontroller)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"You lost!!!" delegate:self cancelButtonTitle:@"Fight another day..." otherButtonTitles:nil];
            av.delegate = self;
            av.tag = 1;
            [av show];
        }
        
        turnIndicator.text = @"Match Ended";
    }else if ([match.currentParticipant.playerID isEqualToString: myPlayer.playerId])
    {
        turnIndicator.text = @"Your Turn";
    }else
    {
        turnIndicator.text = @"Opponent's Turn";
    }
    
    deckCards = currentMatchObj.deckCardList;
    
    // SETTING UP THE REST OF THE VIEW
    
    actorNameLabel.text = currentMatchObj.lastMovieCast;
    
    myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
    myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
    
    otherCardCount.text = [NSString stringWithFormat:@"%d cards", [otherPlayer.playerCardList count]];
    otherPointCount.text = [NSString stringWithFormat:@"%d points", otherPlayer.playerPoints];
    
    [self layoutHand];
}


-(void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Another game needs your attention!" message:notice delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
    [av show];
}

-(void)receiveEndGame:(GKTurnBasedMatch *)match
{
    NSLog(@"%d", match.status);
    
    [self layoutMatch:match];
    
    [match removeWithCompletionHandler:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"%@", error);
        }
    }];
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

#pragma mark Alert View delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"dismissed with button index %d", alertView.tag);
    
    if (alertView.tag == 1)
    {
        GKTurnBasedMatch *match = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
        
        NSMutableString *str = [[NSMutableString alloc] init];
        [str setString:@""];
        
        for (GKTurnBasedParticipant *participant in match.participants)
        {
            NSLog(@"%@ = %d", participant.playerID, participant.status);
            [str appendString:[NSString stringWithFormat:@"%@ = %d \n", participant.playerID, participant.status]];
        }
        
        [match removeWithCompletionHandler:^(NSError *error) {
            NSLog(@"%@ \n %@", error, [error localizedDescription]);
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
