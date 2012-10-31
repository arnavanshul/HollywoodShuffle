//
//  PlayerObject.h
//  Hollywood Shuffle
//
//  Created by AC on 10/8/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum playerStatusTypes
{
    PLAYER_QUIT,
    PLAYER_PLAYING,
    PLAYER_WON,
    PLAYER_LOST
} PlayerState;

@interface PlayerObject : NSObject <NSCoding>
{
    NSMutableString *playerId;
    //NSMutableDictionary *playerCardList;
    NSMutableArray *playerCardList;
    NSInteger playerPoints;
    PlayerState playerStatus;
}

@property (nonatomic, retain) NSMutableString *playerId;
//@property (nonatomic, retain) NSMutableDictionary *playerCardList;
@property (nonatomic, retain) NSMutableArray *playerCardList;
@property (nonatomic, assign) NSInteger playerPoints;
@property (nonatomic, assign) PlayerState playerStatus;

- (id) initWithId:(NSString*)playerId cardList:(NSMutableArray*)cardList points:(NSInteger)playerPoints;
- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)encoder;

@end
