//
//  SInt16Functions.m
//  AudioGenerator
//
//  Created by Ethan Riback on 6/23/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "SInt16Functions.h"

@implementation SInt16Functions

+(SInt16) max:(SInt16 *)array numElements:(int)size {
    SInt16 max = array[0];
    for (int i=0;i<size;i++) {
        if (array[i]>max) {
            max = array[i];
        }
    }
    return max;
}

+(SInt16) min:(SInt16 *)array numElements:(int)size {
    SInt16 min = array[0];
    for (int i=0;i<size;i++) {
        if (array[i]<min) {
            min = array[i];
        }
    }
    return min;
}

/*
+(void) round:(SInt16 *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = roundf(array[i]);
    }
}

+(void) ceil:(SInt16 *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = ceilf(array[i]);
    }
}

+(void) floor:(SInt16 *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = floorf(array[i]);
    }
}
*/

+(SInt16) range:(SInt16 *)array numElements:(int)size {
    SInt16 min = [self min:array numElements:size];
    SInt16 max = [self max:array numElements:size];
    return max-min;
}

@end
