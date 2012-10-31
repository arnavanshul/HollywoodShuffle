//
//  ActorObject.m
//  Hollywood Shuffle
//
//  Created by Arnav Anshul on 9/5/12.
//  Copyright (c) 2012 Arnav Anshul. All rights reserved.
//

#import "ActorObject.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActorObject
@synthesize actorName, actorImageView, actorId;

-(id) init
{
    self = [super init];
    
    if (self)
    {
        actorName = [[NSMutableString alloc] init];
        actorImageView = [[UIImageView alloc] init];
        actorImageView.layer.cornerRadius = 5;
        actorImageView.layer.masksToBounds = YES;
        actorImageView.layer.borderWidth = 2.0f;
    }
    
    return self;
}


-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    ActorObject *temp = [[ActorObject alloc] init];
    
    temp.actorId = self.actorId;
    [temp.actorName setString:self.actorName];
    temp.actorImageView.image = self.actorImageView.image;
    
    return temp;
}


-(id) copy: (ActorObject *)obj
{
    if ([self init])
    {
        [self.actorName setString: obj.actorName];
        self.actorImageView = [[UIImageView alloc] initWithImage: obj.actorImageView.image];
        self.actorImageView.layer.cornerRadius = 5;
        self.actorImageView.layer.masksToBounds = YES;
        self.actorImageView.layer.borderWidth = 2.0f;
        self.actorId = obj.actorId;
    }
    return self;
}


@end
