//
//  COObject.h
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-23.
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


#import <Foundation/Foundation.h>
#import "Cocoadis.h"

@interface COObject : NSObject {
	id obj;
	NSString * name;
	id persistence;
}

@property(retain, readwrite) id obj;
@property(retain, readwrite) NSString * name;

-(id)initAsKey:(NSString *)key;
-(id)initAsKey:(NSString *)key persistence:(id)pers;
-(void)persist;

@end

@interface COArray : COObject {
	
}
+(id)arrayAsKey:(NSString*)key;
+(id)arrayWithArray:(id)anArray asKey:(NSString*)key;
+(id)arrayWithArray:(id)anArray asKey:(NSString*)key persistence:(id)pers;
-(id)initWithArray:(id)anArray asKey:(NSString*)key;
-(id)initWithArray:(id)anArray asKey:(NSString*)key persistence:(id)pers;
-(id)initAsKey:(NSString *)key withObjects:(id)firstObj, ...
NS_REQUIRES_NIL_TERMINATION;
-(id)initAsKey:(NSString *)key persistence:(id)pers withObjects:(id)firstObj, ...
NS_REQUIRES_NIL_TERMINATION;

@end

@interface CODictionary : COObject {
	
}
+(id)dictionaryAsKey:(NSString*)key;
@end

@interface COString : COObject {
	
}
+(id)stringAsKey:(NSString*)key;
@end

@interface COSet : COObject {
	
}
+(id)setAsKey:(NSString*)key;
@end
