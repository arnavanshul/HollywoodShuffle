//
//  PlayerObject.m
//  Hollywood Shuffle
//
//  Created by AC on 10/8/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "PlayerObject.h"

@implementation PlayerObject

#define kPlayerPoints       @"PlayerPoints"
#define kPlayerCards      @"PlayerCardList"
#define kPlayerId      @"PlayerId"
#define kPlayerStatus      @"PlayerStatus"


/*
 0 = quit
 1 = playing
 2 = won
 3 = lost
 */


@synthesize playerId, playerCardList, playerPoints, playerStatus;

- (id) initWithId:(NSString*)pId cardList:(NSMutableArray*)cardList points:(NSInteger)pPoints status:(PlayerState)pStatus
{
    playerId = [[NSMutableString alloc] initWithString: pId];
    playerCardList = [[NSMutableArray alloc] initWithArray: cardList];
    playerPoints = pPoints;
    playerStatus = pStatus;
    
    return self;
}

- (id) init
{
    playerId = [[NSMutableString alloc] init];
    playerCardList = [[NSMutableArray alloc] init];
    playerPoints = -1;
    playerStatus = PLAYER_PLAYING;
    
    return self;
}


- (void) encodeWithCoder:(NSCoder *)encoder // ENCODE
{
    NSLog(@"encoding PlayerObject now....");
    
    [encoder encodeObject:playerId forKey:kPlayerId];
    [encoder encodeObject:playerCardList forKey:kPlayerCards];
    [encoder encodeObject:[NSNumber numberWithInteger: playerPoints] forKey:kPlayerPoints];
    [encoder encodeObject:[NSNumber numberWithInteger: playerStatus] forKey:kPlayerStatus];
}

- (id) initWithCoder:(NSCoder *)decoder //DECODE
{
    if ((self=[super init]))
    {
        NSString *tempPlayerId = [decoder decodeObjectForKey:kPlayerId];
        NSMutableArray *tempPlayerCards = [decoder decodeObjectForKey:kPlayerCards];
        NSNumber *tempPlayerPoints = [decoder decodeObjectForKey:kPlayerPoints];
        NSNumber *tempPlayerStatus = [decoder decodeObjectForKey:kPlayerStatus];
        
        return [self initWithId: tempPlayerId cardList: tempPlayerCards points:[tempPlayerPoints integerValue] status:[tempPlayerStatus integerValue]];
    }
    
    return NULL;
}



@end
