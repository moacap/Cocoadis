//
//  CORedis.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-24.
//  Copyright (c) 2010 Louis-Philippe Perron.
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

#import "CORedis.h"

// Private Methods Interface

@interface CORedis ()

-(NSString*)serialize:(id)obj;
-(id)deserialize:(NSString*)plistString;

@end

// Public Methods implementation

@implementation CORedis
@synthesize name;

- (void)dealloc {
	[name release];
	[redis release];
	[super dealloc];
}

-(id)initAsKey:(NSString*)key redis:(id)red
{
	self = [super init];
	if (self) {
		name = key;
		[name retain];
		redis = red;
		[redis retain];
	}
	return self;
}

// Private methods implementation

-(NSString*)serialize:(id)obj
{
	NSString * className = [[obj class] description];
	if ([obj isKindOfClass:[NSMutableSet class]]) {
		obj = [obj allObjects];
	}
	NSDictionary * plist = [[NSDictionary alloc] initWithObjectsAndKeys:
							className,		@"class",
							obj,			@"object",
							nil];
	NSString * plistString = [plist descriptionInStringsFileFormat];
	[plist release];
	return plistString;
}

-(id)deserialize:(NSString*)plistString
{
	id plist = [plistString propertyListFromStringsFileFormat];
	if ([plist isKindOfClass:[NSDictionary class]]) {
		NSString * className = [plist objectForKey:@"class"];
		if ([className isEqualToString:@"__NSCFSet"] ||
				   [className isEqualToString:@"NSCFSet"]
				   ) {
			return [NSSet setWithArray:[plist objectForKey:@"object"]];
		} else {
			return [plist objectForKey:@"object"];
		}

	}
	return nil;
}

@end

@implementation CORedisArray

- (void)addObject:(id)anObject
{
	[redis commandArgv:[NSArray arrayWithObjects:
						@"RPUSH", self.name, [self serialize:anObject],
						nil]];
}

- (BOOL)containsObject:(id)obj
{
	NSUInteger result = [self indexOfObject:obj];
	if (result == NSNotFound) {
		return NO;
	}
	return YES;
}

- (NSUInteger)count
{
	id result = [redis command:[NSString stringWithFormat:@"LLEN %@", self.name]];
	if ([result isKindOfClass:[NSNumber class]]) {
		return [result unsignedIntegerValue];
	}
	return 0;
}

- (void)getObjects:(id*)aBuffer range:(NSRange)range
{
	for (NSUInteger i = 0; i < range.length; i++) {
		NSUInteger idx = i + range.location;
		aBuffer[i] = [self objectAtIndex:idx];
	}
}

- (id)lastObject
{
	return [self objectAtIndex:-1];
}

- (id)objectAtIndex:(NSUInteger)index
{
	id result = [redis command:[NSString stringWithFormat:@"LINDEX %@ %d", self.name, index]];
	if ([result isKindOfClass:[NSString class]]) {
		return [self deserialize:result];
	}
	return nil;
}

- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes
{
	NSMutableArray * resultArray = [[NSMutableArray alloc] initWithCapacity:[indexes count]];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop) {
		id result = [self objectAtIndex:idx];
		if (result) {
			[resultArray addObject:result];
		}
	}];
	NSArray * returnArray = [NSArray arrayWithArray:resultArray];
	[resultArray release];
	return returnArray;
}

- (NSEnumerator*)objectEnumerator
{
	NSArray * resultArray = [self objectsAtIndexes:
							 [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])]];
	return [resultArray objectEnumerator];
}

- (NSEnumerator*)reverseObjectEnumerator
{
	NSArray * resultArray = [self objectsAtIndexes:
							 [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])]];
	return [resultArray reverseObjectEnumerator];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
	NSEnumerator * arrayEnum = [self objectEnumerator];
	id obj; NSUInteger count = 0; BOOL stop = NO;
	while (obj = [arrayEnum nextObject]) {
		block(obj,count,&stop);
		count++;
		if (stop) {
			break;
		}
	}
}

- (NSUInteger)indexOfObject:(id)anObject
{
	NSUInteger index = 0;
	while (YES) {
		id result = [self objectAtIndex:index];
		if (result) {
			if ([result isEqual:anObject]) {
				return index;
			} else {
				index++;
			}
		} else {
			return NSNotFound;
		}
	}
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{	
	for (NSInteger i = 0; i < range.length; i++) {
		NSInteger idx = i+range.location;
		id result = [self objectAtIndex:idx];
		if ([result isEqual:anObject]) {
			return idx;
		}
	}
	return NSNotFound;
}


@end
