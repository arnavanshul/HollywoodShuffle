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
#define HAND_SCALE_FACTOR 1.1
#define CARD_WIDTH_TAB 63
#define CARD_HEIGHT_TAB 95
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
        
        UIImageView *castBtnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 82, 42)];
        castBtnBg.image = [UIImage imageNamed:@"cast.png"];
        
        [castButton addSubview:castBtnBg];
        
        drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
        drawButton.frame = CGRectMake(400, 265, 82, 42);
        drawButton.backgroundColor = [UIColor clearColor];
        [drawButton addTarget:self action:@selector(drawButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *drawBtnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 82, 42)];
        drawBtnBg.image = [UIImage imageNamed:@"draw.png"];
        
        [drawButton addSubview:drawBtnBg];
        
        handCardListView = [[UIScrollView alloc] init];
        handCardListView.contentSize = CGSizeMake(750, CARD_HEIGHT_PHONE);
        handCardListView.backgroundColor = [UIColor clearColor];
        handCardListView.frame = CGRectMake(0, 215, 370, 100);
        [handCardListView addGestureRecognizer:handLongPressGestureRecognizer];
        handCardListView.canCancelContentTouches = NO;
        
        filmReelListView = [[UIScrollView alloc] init];
        filmReelListView.contentSize = CGSizeMake((CARD_WIDTH_PHONE + 6) * 4, CARD_HEIGHT_PHONE + 30);
        filmReelListView.backgroundColor = [UIColor clearColor];
        [filmReelListView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        filmReelListView.frame = CGRectMake(200, 95, 280, 120);
        [filmReelListView addGestureRecognizer:doubleTapGestureRecognizer];
        [filmReelListView addGestureRecognizer:reelLongPressGestureRecognizer];
        
        settingsView = [[UIView alloc] initWithFrame:CGRectMake(420, 10, 260, 310)];
        settingsView.backgroundColor = [UIColor clearColor];
        [self layoutSettingsView];
        settingsShowing = false;
        
        castMovieView = [[UIView alloc] initWithFrame:CGRectMake(36, 5, 408, 120)];
        castMovieView.backgroundColor = [UIColor clearColor];
        [self layoutCastMovieView];
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
        
        actorTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 80, 225) style:UITableViewStylePlain];
        actorTable.scrollEnabled = TRUE;
        actorTable.dataSource = self;
        actorTable.delegate = self;
        actorTable.backgroundColor = [UIColor clearColor];
        actorTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        myPlayerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 110, 90)];
        myPlayerView.backgroundColor = [UIColor clearColor];
        
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
        
        otherPlayerView = [[UIView alloc] initWithFrame:CGRectMake(145, 0, 150, 90)];
        otherPlayerView.backgroundColor = [UIColor clearColor];
        
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
    
    if([[[UIDevice currentDevice] name] isEqualToString:@"iPad Simulator"])
    {
        actorTable.frame = CGRectMake(0, 300, 150, 350);
        castButton.frame = CGRectMake(800, 450, 250, 50);
        drawButton.frame = CGRectMake(800, 520, 250, 50);
        handCardListView.frame = CGRectMake(180, 420, 580, 220);
        
        [self.view addSubview: actorTable];
    }
    
    [self layoutHand];
}


- (void) viewDidAppear:(BOOL)animated
{
    /*
    actorNameBg.frame = CGRectMake(0, 140, 110, 40);
    [actorNameBg setHidden: FALSE];
     */
    
    if(![appDelegate connectedToInternet])
    {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"NOT CONNNECTED TO INTERNET" message:@"You have to be connected to internet to play this game!!!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noInternet show];
    }
}



- (void) layoutSettingsView
{
    settingsBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 310)];
    settingsBg.image = [UIImage imageNamed:@"bg_border_andgear.png"];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.frame = CGRectMake(0, 0, 60, 60);
    
    UIButton *volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeButton.frame = CGRectMake(142, 15, 40, 30);
    [volumeButton setBackgroundImage:[UIImage imageNamed:@"sound.png"] forState:UIControlStateNormal];
    [volumeButton addTarget:self action:@selector(volumeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *helpButton = [UIButton buttonWithType: UIButtonTypeCustom];
    helpButton.frame = CGRectMake(95, 75, 142, 40);
    [helpButton setBackgroundImage:[UIImage imageNamed:@"help.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(helpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settings2Button = [UIButton buttonWithType: UIButtonTypeCustom];
    settings2Button.frame = CGRectMake(95, 117, 142, 40);
    [settings2Button setBackgroundImage:[UIImage imageNamed:@"settings2.png"] forState:UIControlStateNormal];
    [settings2Button addTarget:self action:@selector(settings2ButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *exitButton = [UIButton buttonWithType: UIButtonTypeCustom];
    exitButton.frame = CGRectMake(95, 159, 142, 40);
    [exitButton setBackgroundImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *quitButton = [UIButton buttonWithType: UIButtonTypeCustom];
    quitButton.frame = CGRectMake(95, 201, 142, 40);
    [quitButton setBackgroundImage:[UIImage imageNamed:@"quit-game.png"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *frndsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(95, 245, 142, 40)];
    frndsOnline.image = [UIImage imageNamed:@"friends.png"];
    
    [settingsView addSubview: settingsBg];
    [settingsView addSubview: settingsButton];
    [settingsView addSubview: volumeButton];
    [settingsView addSubview: helpButton];
    [settingsView addSubview: settings2Button];
    [settingsView addSubview: exitButton];
    [settingsView addSubview: quitButton];
    [settingsView addSubview: frndsOnline];
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
    movieName.backgroundColor = [UIColor clearColor];
    
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
    float tempWidth = (CARD_WIDTH_PHONE * HAND_SCALE_FACTOR);
    for (int i = 0; i < [cardsInHand count]; i++)
    {
        ActorObject *temp = [cardsInHand objectAtIndex: i];
        NSLog(@"card in hand object actor id %d",temp.actorId);
        UIImageView *view = temp.actorImageView;
        view.frame = CGRectMake(i * tempWidth, 0, tempWidth, CARD_HEIGHT_PHONE * HAND_SCALE_FACTOR);
        [handCardListView addSubview: view];
        view.layer.borderColor = [UIColor blackColor].CGColor;
    }

    handCardListView.contentSize = CGSizeMake(([cardsInHand count]) * tempWidth, CARD_HEIGHT_PHONE);
    
    //EMPTYING THE REEL SCROLLVIEW
    for (UIView *view in [filmReelListView subviews])
    {
        [view removeFromSuperview];
    }
    
    //ADDING IMAGES TO REEL
    filmReelListView.contentSize = CGSizeMake(([cardsOnReel count] + 1) * 70, CARD_HEIGHT_PHONE);
    
    int x = 0;
    for (int i = 0; i < [cardsOnReel count]; i++)
    {
        ActorObject *temp = [cardsOnReel objectAtIndex: i];
        
        UIImageView *cardBg = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, 70, 120)];
        cardBg.backgroundColor = [UIColor clearColor];
        cardBg.image = [UIImage imageNamed:@"reel_1.png"];
        
        UIImageView *cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(3, 15, CARD_WIDTH_PHONE, CARD_HEIGHT_PHONE)];
        cardImage.image = temp.actorImageView.image;
        cardImage.layer.cornerRadius = 5;
        cardImage.layer.masksToBounds = YES;
        cardImage.layer.borderWidth = 1.0f;
        cardImage.layer.borderColor = [UIColor clearColor].CGColor;
        
        [cardBg addSubview:cardImage];
        [filmReelListView addSubview: cardBg];
        
        x = x + 70;
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
        crossReelImage.frame = CGRectMake(x, 0, 70, 120);
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
        
        selectedCardNum = doubleTapLocation.x/(CARD_WIDTH_PHONE + 6);
        
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
            selectedCardNum = longPressLocation.x/(CARD_WIDTH_PHONE * HAND_SCALE_FACTOR);
            NSLog(@"selected card is = %d", selectedCardNum);
            if (selectedCardNum < [cardsInHand count])
            {
                cardSelectedFromHand = [cardsInHand objectAtIndex:selectedCardNum];
                
                
                //TO DO: WRITE AN OBJECT COPYING METHOD FOR ACTOR OBJECT. PROBLEM: IMAGE OR IMAGEVIEW DOES NOT HAVE A 
                cardSelected = [cardSelectedFromHand copy];
                cardSelected.actorImageView.frame = cardSelectedFromHand.actorImageView.frame;
                
                cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
                cardSelected.actorImageView.center = locationOnScreen;
                cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - 60);
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
            
            NSLog(@"");
            CGPoint temp = [sender locationInView:filmReelListView];
                        
            if (temp.y > 0 && temp.y < 80 && temp.x > 0 && [[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch: [[GCTurnBasedMatchHelper
                                                                                                                        sharedInstance] currentMatch]])
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
        selectedCardNum = longPressLocation.x/(CARD_WIDTH_PHONE + 6);
        NSLog(@"the selected card = %d", selectedCardNum);
        NSLog(@"card count on reel = %d", [cardsOnReel count]);
        if(selectedCardNum < [cardsOnReel count])
        {
            ActorObject *cardSelectedOnReel = [cardsOnReel objectAtIndex:selectedCardNum];
            
            cardSelected = [cardSelectedOnReel copy];
            cardSelected.actorImageView.frame = CGRectMake(0, 0, CARD_WIDTH_PHONE, CARD_HEIGHT_PHONE);
            cardSelected.actorImageView.transform = CGAffineTransformScale(cardSelected.actorImageView.transform, 1.5, 1.5);
            cardSelected.actorImageView.center = locationOnScreen;
            cardSelected.actorImageView.center = CGPointMake(cardSelected.actorImageView.center.x, cardSelected.actorImageView.center.y - 60);
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
                
                for (GKTurnBasedParticipant *participant in match.participants)
                {
                    NSLog(@"%@ = %d", participant.playerID, participant.status);
                }
                
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
            
        }else
        {
            
        }
        
        //actorNameLabel.text = @"";
        
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
                NSLog(@"Send Turn, %@, %@", currentMatchData, nextParticipant);
            }
        }
    }else
    {
        /*
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message: @"Its not your turn..."
                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
         */
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
    [self.navigationController popViewControllerAnimated:YES];
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
    //return true;
    
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
    
    while ([cardsInHand count] < 5)
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
    
    if([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:match])
    {
        castButton.enabled = true;
        drawButton.enabled = true;
    }else
    {
        castButton.enabled = false;
        drawButton.enabled = false;
    }
    
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
    turnIndicator.text = @"Your Turn";
    
    currentMatchObj = [NSKeyedUnarchiver unarchiveObjectWithData: match.matchData];
    
    deckCards = currentMatchObj.deckCardList;
    
    if([currentMatchObj.playersList objectForKey: match.currentParticipant.playerID])
    {
        myPlayer = [currentMatchObj.playersList objectForKey: match.currentParticipant.playerID];
        
        [cardsInHand removeAllObjects];
        
        for (NSNumber *tempActorId in myPlayer.playerCardList)
        {
            [cardsInHand addObject:[appDelegate.all52Cards objectForKey:tempActorId]];
        }
        
    }else //joining player's first turn
    {
        while ([cardsInHand count] < 5)
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
    }
    
    [cardsOnReel removeAllObjects];
    [cardsOnReel addObject:[appDelegate.all52Cards objectForKey:[NSNumber numberWithInteger: currentMatchObj.lastActorCast]]];
    
    actorNameLabel.text = currentMatchObj.lastMovieCast;
    
    if([[GCTurnBasedMatchHelper sharedInstance] isMyTurnforMatch:match])
    {
        castButton.enabled = true;
        drawButton.enabled = true;
    }else
    {
        castButton.enabled = false;
        drawButton.enabled = false;
    }
    
    for (NSString *playerId in [currentMatchObj.playersList allKeys])
    {
        if (![playerId isEqualToString: myPlayer.playerId])
        {
            otherPlayer = [currentMatchObj.playersList objectForKey:playerId];
            
            if (otherPlayer.playerStatus == PLAYER_QUIT)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"The other player quit. You are the winner..."
                                                            delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
                av.delegate = self;
                av.tag = 1;
                [av show];
                
                [myPlayer setPlayerStatus: PLAYER_WON];
                
                NSLog(@"%@", match.currentParticipant.playerID);
                NSLog(@"%@", myPlayer.playerId);
                
                NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                                   [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
                
                
                //Set the match outcome for all the participants...
                for(GKTurnBasedParticipant *participant in match.participants)
                {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                }
                
                match.currentParticipant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                
                [match endMatchInTurnWithMatchData:currentMatchData completionHandler:^(NSError *error)
                {
                    if (error)
                    {
                        NSLog(@"completion handler %@", error);
                    }
                    
                    NSLog(@"completion handler state of the match = %d", match.status);
                }];
                
                NSLog(@"state of the match = %d", match.status);
                
            }else if (otherPlayer.playerStatus == PLAYER_WON)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"You lost!!!" delegate:self cancelButtonTitle:@"Fight another day..." otherButtonTitles:nil];
                av.delegate = self;
                av.tag = 1;
                [av show];
                
                [myPlayer setPlayerStatus: PLAYER_LOST];
                
                NSLog(@"%@", match.currentParticipant.playerID);
                NSLog(@"%@", myPlayer.playerId);
                
                NSMutableData *currentMatchData = [[NSMutableData alloc] initWithData:
                                                   [NSKeyedArchiver archivedDataWithRootObject:currentMatchObj]];
                
                for(GKTurnBasedParticipant *participant in match.participants)
                {
                    if (![participant.playerID isEqualToString:otherPlayer.playerId])
                    {
                        participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                    }else
                    {
                        participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                    }
                }
                
                [match endMatchInTurnWithMatchData:currentMatchData completionHandler:^(NSError *error)
                 {
                     if (error)
                     {
                         //Have to look at it.... might be something due to scores not being reported to the game center leaderboard.
                         
                         NSLog(@"completion handler %@", error);
                     }
                     
                     NSLog(@"completion handler state of the match = %d", match.status);
                 }];
            }
        }
    }
    
    // SETTING UP THE REST OF THE VIEW
    
    actorNameLabel.text = currentMatchObj.lastMovieCast;
    
    myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
    myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
    
    otherCardCount.text = [NSString stringWithFormat:@"%d cards", [otherPlayer.playerCardList count]];
    otherPointCount.text = [NSString stringWithFormat:@"%d points", otherPlayer.playerPoints];
    
    [self layoutHand];
}


-(void)layoutMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"Viewing match where it's not our turn...");
    
    currentMatchObj = [NSKeyedUnarchiver unarchiveObjectWithData: match.matchData];
    
    myPlayer = [currentMatchObj.playersList objectForKey:[[GKLocalPlayer localPlayer] playerID]];
    
    for (NSString *playerId in [currentMatchObj.playersList allKeys])
    {
        if (![playerId isEqualToString: myPlayer.playerId])
        {
            otherPlayer = [currentMatchObj.playersList objectForKey:playerId];
            
            if (otherPlayer.playerStatus == PLAYER_QUIT)
            {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"The other player quit. You are the winner..."
                                                            delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
                av.tag = 1;
                [av show];
                
                [myPlayer setPlayerStatus: PLAYER_WON];
                
                [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeWon nextParticipant:nil matchData:match.matchData completionHandler:nil];
            }
        }
    }
    
    //for (NSNumber *key in [myPlayer.playerCardList allKeys])
    for (NSNumber *key in myPlayer.playerCardList)
    {
        [cardsInHand addObject: [appDelegate.all52Cards objectForKey:key]];
    }
    
    [cardsOnReel addObject: [appDelegate.all52Cards objectForKey: [NSNumber numberWithInteger:currentMatchObj.lastActorCast]]];
    deckCards = currentMatchObj.deckCardList;
    
    if (match.status == GKTurnBasedMatchStatusEnded)
    {
        turnIndicator.text = @"Match Ended";
        
        UIAlertView *av;
        
        if(myPlayer.playerStatus == PLAYER_WON)
        {
            av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"You Won!!!" delegate:self cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
        }else
        {
            av = [[UIAlertView alloc] initWithTitle: @"Game Alert !" message: @"You lost!!!" delegate:self cancelButtonTitle:@"Fight another day..." otherButtonTitles:nil];
        }
        
        av.tag = 1;
        [av show];
        
    } else
    {
        NSLog(@"%@",turnIndicator);
        turnIndicator.text = @"Opponent's Turn";
    }
    
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
    
    NSMutableString *str = [[NSMutableString alloc] init];
    for (GKTurnBasedParticipant *participant in match.participants)
    {
        NSLog(@"%@ = %d", participant.playerID, participant.status);
        [str appendString:[NSString stringWithFormat:@"%@ = %d \n", participant.playerID, participant.status]];
    }
    
    [match removeWithCompletionHandler:^(NSError *error) {
        NSLog(@"%@ \n %@", error, [error localizedDescription]);
    }];
    
    NSLog(@"%@", str);
    
    // SETTING UP THE REST OF THE VIEW
    
    actorNameLabel.text = currentMatchObj.lastMovieCast;
    
    myCardCount.text = [NSString stringWithFormat:@"%d cards", [myPlayer.playerCardList count]];
    myPointCount.text = [NSString stringWithFormat:@"%d points", myPlayer.playerPoints];
    
    otherCardCount.text = [NSString stringWithFormat:@"%d cards", [otherPlayer.playerCardList count]];
    otherPointCount.text = [NSString stringWithFormat:@"%d points", otherPlayer.playerPoints];
    
    [self layoutMatch:match];
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

#pragma mark Table View datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cardsInHand count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] ;
    }
    
    ActorObject *temp = [cardsInHand objectAtIndex:indexPath.row];
    
    UILabel *actorNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 75, 30)];
    actorNameLbl.text = temp.actorName;
    //UIFont *font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:8.0];
    
    actorNameLbl.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:13];
    actorNameLbl.numberOfLines = 0;
    //actorNameLbl.textAlignment = UITextAlignmentCenter;
    actorNameLbl.backgroundColor = [UIColor clearColor];
    actorNameLbl.textColor = [UIColor whiteColor];
    
    if(selectedRow == indexPath.row)
    {
        actorNameLbl.font = [UIFont fontWithName:@"DINEngschrift-Alternate" size:12];
        actorNameLbl.textColor = [UIColor yellowColor];
        selectedRow = -1;
    }
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 33)];
    bg.image = [UIImage imageNamed:@"left_nav_button_02.png"];
    
    [cell.contentView addSubview:bg];
    [cell.contentView addSubview:actorNameLbl];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"left_nav_button_02.png"]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //card selection
    selectedRow = indexPath.row;
    
    [actorTable reloadData];
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
