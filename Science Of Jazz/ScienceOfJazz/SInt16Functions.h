//
//  SInt16Functions.h
//  AudioGenerator
//
//  Created by Ethan Riback on 6/27/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SInt16Functions : NSObject

//+(void) sort:(SInt16*)array numElements:(int)size;

+(SInt16) max:(SInt16*)array numElements:(int)size;

+(SInt16) min:(SInt16*)array numElements:(int)size;

/*
+(void) round:(SInt16*)array numElements:(int)size;

+(void) floor:(SInt16*)array numElements:(int)size;

+(void) ceil:(SInt16*)array numElements:(int)size;
 */

+(SInt16) range:(SInt16*)array numElements:(int)size;

@end
