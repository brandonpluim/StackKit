//
//  SKTag.m
//  StackKit
//
//  Created by Dave DeLong on 1/25/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "StackKit_Internal.h"

NSString * SKTagName = @"name";
NSString * SKTagCount = @"count";

NSUInteger SKTagDefaultPageSize = 70;

@implementation SKTag

@synthesize name;
@synthesize numberOfTaggedQuestions;

+ (NSDictionary *) APIAttributeToPropertyMapping {
	static NSDictionary * _kSKTagMappings = nil;
	if (_kSKTagMappings == nil) {
		_kSKTagMappings = [[NSDictionary alloc] initWithObjectsAndKeys:
							 @"name", SKTagName,
							 @"numberOfTaggedQuestions", SKTagCount,
							 nil];
	}
	return _kSKTagMappings;
}

+ (NSPredicate *) updatedPredicateForFetchRequest:(SKFetchRequest *)request {
	return [[request predicate] predicateByRemovingSubPredicateWithLeftExpression:[NSExpression expressionForKeyPath:SKUserID]];
}

+ (NSURL *) apiCallForFetchRequest:(SKFetchRequest *)request error:(NSError **)error {
	/**
	 Valid endpoints:
	 
	 /tags (defaults to /tags/popular)
	 /tags/popular (sort by count descending)
	 /tags/name (sort by name ascending)
	 /tags/recent (sort by something magical)
	 /users/{id}/tags - tags in which user {id} has participated
	 
	 **/
	
	NSMutableString * relativeString = [NSMutableString string];
	
	NSPredicate * predicate = [request predicate];
	id tagsForUser = [predicate constantValueForLeftExpression:[NSExpression expressionForKeyPath:SKUserID]];
	if (predicate != nil && tagsForUser != nil) {
		NSNumber * userID = nil;
		if ([tagsForUser isKindOfClass:[NSNumber class]]) {
			userID = tagsForUser;
		} else {
			userID = [NSNumber numberWithInt:[[tagsForUser description] intValue]];
		}
		[relativeString appendFormat:@"/users/%@/tags", userID];
	} else {
		//we'll sort by "recent" by default, since there's no convenient way to specify that in a sort descriptor (yet)
		NSString * sort = @"recent";
		for (NSSortDescriptor * sortDescriptor in [request sortDescriptors]) {
			if ([[sortDescriptor key] isEqual:SKTagName]) {
				sort = @"name";
				break;
			} else if ([[sortDescriptor key] isEqual:SKTagCount]) {
				sort = @"popular";
				break;
			}
		}
		[relativeString appendFormat:@"/tags/%@", sort];
	}
	
	NSMutableDictionary * query = [NSMutableDictionary dictionary];
	[query setObject:[[request site] apiKey] forKey:SKSiteAPIKey];
	
	if ([request fetchOffset] != 0 || [request fetchLimit] != 0) {
		NSUInteger pagesize = ([request fetchLimit] > 0 ? [request fetchLimit] : SKTagDefaultPageSize);
		NSUInteger page = ([request fetchOffset] > 0 ? floor([request fetchOffset]/pagesize) : 1);
		
		[query setObject:[NSNumber numberWithUnsignedInteger:pagesize] forKey:SKPageSizeKey];
		[query setObject:[NSNumber numberWithUnsignedInteger:page] forKey:SKPageKey];
	}
	
	NSURL * apiCall = [[self class] constructAPICallForBaseURL:[[request site] apiURL] relativePath:relativeString query:query];
	
	NSLog(@"api: %@", apiCall);
	
	return apiCall;
}

- (id) initWithSite:(SKSite *)aSite dictionaryRepresentation:(NSDictionary *)dictionary {
	if (self = [super initWithSite:aSite]) {
		name = [[dictionary objectForKey:SKTagName] retain];
		numberOfTaggedQuestions = [[dictionary objectForKey:SKTagCount] unsignedIntegerValue];
	}
	return self;
}

- (BOOL) isEqual:(id)object {
	if ([object isKindOfClass:[self class]] == NO) {
		return NO;
	}
	
	return [[self name] isEqual:[object name]];
}

- (void) dealloc {
	[name release];
	
	[super dealloc];
}

@end
