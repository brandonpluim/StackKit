//
//  _SKRequestBuilderUsersByID.m
//  StackKit
/**
  Copyright (c) 2011 Dave DeLong
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/

#import "_SKRequestBuilderUsersByID.h"
#import "SKUser.h"

@implementation _SKRequestBuilderUsersByID

+ (Class) recognizedFetchEntity {
	return [SKUser class];
}

+ (NSDictionary *) recognizedPredicateKeyPaths {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			SK_BOX(NSEqualToPredicateOperatorType, NSInPredicateOperatorType), @"userID",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"creationDate",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"reputation",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"displayName",
			nil];
}

+ (NSSet *) requiredPredicateKeyPaths {
	return [NSSet setWithObjects:
			@"userID",
			nil];
}

+ (NSDictionary *) recognizedSortDescriptorKeys {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			SKSortCreation, @"creationDate",
			SKSortReputation, @"reputation",
			SKSortName, @"displayName",
			nil];
}

- (void) buildURL {
	NSPredicate * p = [self requestPredicate];
	
	id users = [p constantValueForLeftKeyPath:@"userID"];
	[self setPath:[NSString stringWithFormat:@"/users/%@", SKExtractUserID(users)]];
	
	SKRange dateRange = [p rangeOfConstantValuesForLeftKeyPath:@"creationDate"];
	if (dateRange.lower != SKNotFound) {
		[[self query] setObject:dateRange.lower forKey:SKQueryFromDate];
	}
	if (dateRange.upper != SKNotFound) {
		[[self query] setObject:dateRange.upper forKey:SKQueryToDate];
	}
	
	if ([self requestSortDescriptor] != nil && ![[[self requestSortDescriptor] key] isEqual:@"creationDate"]) {
		SKRange sortRange = [p rangeOfConstantValuesForLeftKeyPath:[[self requestSortDescriptor] key]];
		if (sortRange.lower != SKNotFound) {
			[[self query] setObject:sortRange.lower forKey:SKQueryMinSort];
		}
		if (sortRange.upper != SKNotFound) {
			[[self query] setObject:sortRange.upper forKey:SKQueryMaxSort];
		}
	}
	
	id filter = [p constantValueForLeftKeyPath:@"displayName"];
	if (filter != nil) {
		[[self query] setObject:filter forKey:SKQueryFilter];
	}
	
	[super buildURL];
}

@end
