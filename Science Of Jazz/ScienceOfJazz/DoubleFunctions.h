//
//  DoubleFunctions.h
//  AudioGenerator
//
//  Created by Ethan Riback on 6/27/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoubleFunctions : NSObject

//+(void) sort:(double*)array numElements:(int)size;

+(double) max:(double*)array numElements:(int)size;

+(double) min:(double*)array numElements:(int)size;

+(void) round:(double*)array numElements:(int)size;

+(void) floor:(double*)array numElements:(int)size;

+(void) ceil:(double*)array numElements:(int)size;

+(double) range:(double*)array numElements:(int)size;

@end
