//
//  SKQuestion.m
//  StackKit
//
//  Created by Dave DeLong on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKQuestion.h"
#import <StackKit/SKConstants.h>
#import <StackKit/SKObject_Internal.h>

@implementation SKQuestion

@dynamic questionID;
@dynamic lastEditDate;
@dynamic creationDate;
@dynamic lastActivityDate;
@dynamic lockedDate;
@dynamic score;
@dynamic communityOwnedDate;
@dynamic answerCount;
@dynamic acceptedAnswerID;
@dynamic bountyClosesDate;
@dynamic bountyAmount;
@dynamic closedDate;
@dynamic protectedDate;
@dynamic body;
@dynamic title;
@dynamic closedReason;
@dynamic upVoteCount;
@dynamic downVoteCount;
@dynamic favoriteCount;
@dynamic viewCount;
@dynamic ownerID;
@dynamic isAnswered;

+ (NSString *)_uniquelyIdentifyingAPIKey {
    return SKAPIKeys.question.questionID;
}

+ (NSArray *)APIKeysBackingProperties {
    static dispatch_once_t onceToken;
    static NSArray *keys = nil;
    dispatch_once(&onceToken, ^{
        keys = [[NSArray alloc] initWithObjects:
                SKAPIKeys.question.questionID,
                SKAPIKeys.question.lastEditDate,
                SKAPIKeys.question.creationDate,
                SKAPIKeys.question.lastActivityDate,
                SKAPIKeys.question.lockedDate,
                SKAPIKeys.question.score,
                SKAPIKeys.question.communityOwnedDate,
                SKAPIKeys.question.answerCount,
                SKAPIKeys.question.acceptedAnswerID,
                SKAPIKeys.question.bountyClosesDate,
                SKAPIKeys.question.bountyAmount,
                SKAPIKeys.question.closedDate,
                SKAPIKeys.question.protectedDate,
                SKAPIKeys.question.body,
                SKAPIKeys.question.title,
                SKAPIKeys.question.closedReason,
                SKAPIKeys.question.upVoteCount,
                SKAPIKeys.question.downVoteCount,
                SKAPIKeys.question.favoriteCount,
                SKAPIKeys.question.viewCount,
                @"owner_id",
                SKAPIKeys.question.isAnswered,
                nil];
    });
    return keys;
}

+ (NSDictionary *)_mutateResponseDictionary:(NSDictionary *)d {
    NSDictionary *owner = [d objectForKey:SKAPIKeys.question.owner];
    if (owner) {
        NSMutableDictionary *md = [d mutableCopy];
        
        id userID = [owner objectForKey:SKAPIKeys.user.userID];
        if (userID) {
            [md setObject:userID forKey:@"owner_id"];
        }
        
        d = [md autorelease];
    }
    return d;
}

@end
