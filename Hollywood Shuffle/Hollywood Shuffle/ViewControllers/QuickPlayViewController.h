//
//  QuickPlayViewController.h
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 8/27/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCRealTimeMatchHelper.h"
#import "GCTurnBasedMatchHelper.h"

@class ActorObject, QuickPlayMatchObject, PlayerObject, AppDelegate;
@interface QuickPlayViewController : UIViewController <UIGestureRecognizerDelegate, GCTurnBasedMatchHelperDelegate, UIAlertViewDelegate>

{
    NSInteger selectedRow, selectedCardNum;
    NSInteger CARD_HEIGHT, CARD_WIDTH, REEL_WIDTH, REEL_HEIGHT, HAND_SCALE_FACTOR;
    
    BOOL settingsShowing, castMovieViewShowing;
    
    NSMutableArray *cardsInHand, *cardsOnReel, *cardsPlacedThisHand;
    NSMutableDictionary *deckCards;
    ActorObject *cardSelected, *cardSelectedFromHand, *cardAddedToReel;
    
    QuickPlayMatchObject *currentMatchObj;
    PlayerObject *myPlayer, *otherPlayer;
    
    AppDelegate *appDelegate;
    
    UITapGestureRecognizer *doubleTapGestureRecognizer;
    UILongPressGestureRecognizer *handLongPressGestureRecognizer, *reelLongPressGestureRecognizer;
    
    UIView *settingsView, *castMovieView, *myPlayerView, *otherPlayerView;
    UIScrollView *handCardListView, *filmReelListView;
    UIImageView *actorNameBg, *settingsBg;
    //UIImageView *bgView, *deckStack;
    UIImageView *myPlayerImage, *otherPlayerImage;
    UILabel *actorNameLabel, *turnIndicator;
    UILabel *myCardCount, *otherCardCount, *myPointCount, *otherPointCount;
    UITextField *movieName;
    UIButton *castButton, *drawButton;
}


/*
 *
 *
 *
 *
 ************************ NOTE FOR FUTURE DEVELOPERS WORKING ON THIS CODE ************************
 
 A GLOSSARY OF VIEWS AND OTHER RELEVANT OBJECTS USED FOR THE IMPLEMENTATION OF THE GAME (gets confusing with similar sounding variable names. my bad)
 
 
 ****handCardListView****               UIScrollView (canvas for the images of the cards in hand for the user)
 
 *cardsInHand*                          NSMutableArray (array of ActorObject instances. Each contains the name and image for an actor)
 
 actorsArray                            NSMutableArray (array that populates the tableview on the left side (now gone for iPhone/iPod. I believe will stay on for an iPad). will be merged into the cardsInHand  array)
 
 **cardSelectedFromHand**               one of the objects from *cardsInHand* array (to be kept as a record for the image to be removed from the ****handCardListView****. Not really being used for that purpose though. Will have to figure out if can be gotten rid of altogether)
 
 ***cardSelected***                     copy of **cardSelectedFromHand** (Used to serve as the image when dragging the actor image around the screen.)
 
 cardAddedToReel                        copy of ***cardSelected*** (The card that is placed on the playreel)
 
 cardCountOnReel                        used to calculate the frame for the next card to be added...
 
 filmReelListView                       UIScrollView (canvas for the images already on the playreel)
 
 *
 *
 *
 *
 */

@end
