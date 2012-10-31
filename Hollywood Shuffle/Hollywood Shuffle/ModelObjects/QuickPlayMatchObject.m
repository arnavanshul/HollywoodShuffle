//
//  QuickPlayMatchData.m
//  Hollywood Shuffle
//
//  Created by AC on 10/1/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "QuickPlayMatchObject.h"


@implementation QuickPlayMatchObject

/*
movietitle
other player points
card that the other player cast / if he drew a card
*/

#define kLastMovieCast       @"LastMovieCast"
#define kLastActorCast      @"LastActorCast"
#define kPlayersDictionary      @"PlayersDictionary"
#define kCardsOnDeck      @"CardsOnDeck"

@synthesize lastActorCast, lastMovieCast, playersList, deckCardList;

- (id) initWithLastActorCast:(NSNumber *)actorId lastMovieCast:(NSString *)movieTitle playersDetails:(NSMutableDictionary *)playersDetails cardsOnDeck:(NSMutableDictionary *)deckCards
{
    if ((self=[super init]))
    {
        lastActorCast = [actorId integerValue];
        lastMovieCast = [[NSMutableString alloc] initWithString:movieTitle];
        playersList = [[NSMutableDictionary alloc] initWithDictionary:playersDetails];
        deckCardList = [[NSMutableDictionary alloc] initWithDictionary:deckCards];
    }
    
    return self;
}

- (id) init
{
    if ((self=[super init]))
    {
        lastActorCast = -1;
        lastMovieCast = [[NSMutableString alloc] init];
        playersList = [[NSMutableDictionary alloc] init];
        deckCardList = [[NSMutableDictionary alloc] init];
    }
    return  self;
}

- (void) encodeWithCoder:(NSCoder *)encoder // ENCODE
{
    NSLog(@"encoding QuickplayMatchObject now....");
    NSLog(@"movie title is = ___%@___", self.lastMovieCast);
    [encoder encodeObject:lastMovieCast forKey:kLastMovieCast];
    [encoder encodeObject:[NSNumber numberWithInteger: lastActorCast] forKey:kLastActorCast];
    [encoder encodeObject:playersList forKey:kPlayersDictionary];
    [encoder encodeObject:deckCardList forKey:kCardsOnDeck];
}

- (id) initWithCoder:(NSCoder *)decoder //DECODE
{
    if ((self=[super init]))
    {
        NSString *tempMovie = [decoder decodeObjectForKey:kLastMovieCast];
        NSNumber *tempLastActor = [decoder decodeObjectForKey:kLastActorCast];
        NSMutableDictionary *tempPlayersList = [decoder decodeObjectForKey:kPlayersDictionary];
        NSMutableDictionary *tempDeckCards = [decoder decodeObjectForKey:kCardsOnDeck];
        
        return [self initWithLastActorCast:tempLastActor lastMovieCast:tempMovie playersDetails:tempPlayersList cardsOnDeck:tempDeckCards];
    }
    
    return NULL;
}

@end
