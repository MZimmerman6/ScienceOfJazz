//
//  DoubleFunctions.m
//  AudioGenerator
//
//  Created by Ethan Riback on 6/27/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "DoubleFunctions.h"

@implementation DoubleFunctions

+(double) max:(double *)array numElements:(int)size {
    double max = array[0];
    for (int i=0;i<size;i++) {
        if (array[i]>max) {
            max = array[i];
        }
    }
    return max;
}

+(double) min:(double *)array numElements:(int)size {
    double min = array[0];
    for (int i=0;i<size;i++) {
        if (array[i]<min) {
            min = array[i];
        }
    }
    return min;
}

+(void) round:(double *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = roundf(array[i]);
    }
}

+(void) ceil:(double *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = ceilf(array[i]);
    }
}

+(void) floor:(double *)array numElements:(int)size {
    for (int i = 0;i<size;i++) {
        array[i] = floorf(array[i]);
    }
}

+(double) range:(double *)array numElements:(int)size {
    double min = [self min:array numElements:size];
    double max = [self max:array numElements:size];
    return max-min;
}

@end
