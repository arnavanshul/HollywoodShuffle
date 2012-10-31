//
//  ActorObject.h
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 9/5/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActorObject : NSObject<NSCopying>
{
    NSMutableString *actorName;
    UIImageView *actorImageView;
    NSInteger actorId;
}

@property(nonatomic, retain) NSMutableString *actorName;
@property(nonatomic, retain) UIImageView *actorImageView;
@property(nonatomic, assign) NSInteger actorId;

@end
