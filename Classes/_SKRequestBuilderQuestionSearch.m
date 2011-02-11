//
//  _SKRequestBuilderQuestionSearch.m
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

#import "_SKRequestBuilderQuestionSearch.h"
#import "SKQuestion.h"


@implementation _SKRequestBuilderQuestionSearch

+ (Class) recognizedFetchEntity {
	return [SKQuestion class];
}

+ (NSDictionary *) recognizedPredicateKeyPaths {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			SK_BOX(NSContainsPredicateOperatorType), @"title",
			SK_BOX(NSContainsPredicateOperatorType), @"tags",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"lastActivityDate",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"viewCount",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"creationDate",
			SK_BOX(NSGreaterThanOrEqualToPredicateOperatorType, NSLessThanOrEqualToPredicateOperatorType), @"score",
			nil];
}

+ (NSDictionary *) recognizedSortDescriptorKeys {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			SKSortActivity, @"lastActivityDate",
			SKSortViews, @"viewCount",
			SKSortCreation, @"creationDate",
			SKSortVotes, @"score",
			nil];
}

- (void) buildURL {
	NSPredicate * p = [self requestPredicate];
	
	id inTitle = [p constantValueForLeftKeyPath:@"title"];
	id tagged = [p constantValueForLeftKeyPath:@"tags"];
	
	if (inTitle == nil && tagged == nil) {
		[self setError:SK_PREDERROR(@"Searching requires a title or tag predicate")];
		return;
	}
	
	if (inTitle != nil) {
		[[self query] setObject:inTitle forKey:SKQueryInTitle];
	}
	
	if (tagged != nil) {
		[[self query] setObject:SKExtractTagName(tagged) forKey:SKQueryTagged];
	}
	
	//TODO: nottagged?
	
	[[self query] setObject:SKQueryTrue forKey:SKQueryBody];
	
	[self setPath:@"/search"];
	
	if ([self requestSortDescriptor] != nil) {
		SKRange sortRange = [p rangeOfConstantValuesForLeftKeyPath:[[self requestSortDescriptor] key]];
		if (sortRange.lower != SKNotFound) {
			[[self query] setObject:sortRange.lower forKey:SKQueryMinSort];
		}
		if (sortRange.upper != SKNotFound) {
			[[self query] setObject:sortRange.upper forKey:SKQueryMaxSort];
		}
	}
	
	[super buildURL];
}

@end
