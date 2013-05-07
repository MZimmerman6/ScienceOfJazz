//
//  IntFunctions.m
//  ScienceOfJazz
//
//  Created by ExCITe on 4/12/13.
//
//

#import "IntFunctions.h"

@implementation IntFunctions

+(int) max:(int*)array start:(int)start end:(int)end {
    int maxValue = -INT32_MIN;
    for (int i = start;i<=end;i++) {
        if (array[i] > maxValue) {
            maxValue = array[i];
        }
    }
    return  maxValue;
}


+(int) min:(int*)array start:(int)start end:(int)end {
    int minValue = INT32_MAX;
    for (int i = start;i<=end;i++) {
        if (array[i] < minValue) {
            minValue = array[i];
        }
    }
    return  minValue;
}

@end
