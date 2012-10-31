//
//  QuickPlayMatchData.h
//  Hollywood Shuffle
//
//  Created by AC on 10/1/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 movietitle
 other player points
 card that the other player cast / if he drew a card
 */

@interface QuickPlayMatchObject : NSObject <NSCoding>
{
    NSMutableString *lastMovieCast;
    NSMutableDictionary *playersList;
    NSMutableDictionary *deckCardList;
    NSInteger lastActorCast;
}

@property (nonatomic, assign) NSInteger lastActorCast;
@property (nonatomic, retain) NSMutableString *lastMovieCast;
@property (nonatomic, retain) NSMutableDictionary *playersList;
@property (nonatomic, retain) NSMutableDictionary *deckCardList;

- (id) initWithLastActorCast:(NSNumber *)actorId lastMovieCast:(NSString *)movieTitle playersDetails:(NSMutableDictionary *)playersDetails cardsOnDeck:(NSMutableDictionary *)deckCards;
- (id) initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end
