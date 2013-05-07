//
//  FloatFunctions.m
//  ScienceOfJazz
//
//  Created by ExCITe on 4/12/13.
//
//

#import "FloatFunctions.h"

@implementation FloatFunctions


+(float) max:(float *)array start:(int)start end:(int)end {
    float maxValue = -MAXFLOAT;
    for (int i = start;i<=end;i++) {
        if (array[i] > maxValue) {
            maxValue = array[i];
        }
    }
    return  maxValue;
}


+(float) min:(float *)array start:(int)start end:(int)end {
    float minValue = MAXFLOAT;
    for (int i = start;i<=end;i++) {
        if (array[i] < minValue) {
            minValue = array[i];
        }
    }
    return  minValue;
}

+(float*) linspace:(float)start end:(float)end numElements:(int)numElements {
    
    float *values = (float*)calloc(numElements, sizeof(float));
    float jump = (end-start)/((float)numElements-1);
    for (int i = 0;i<numElements;i++) {
        values[i] = start+jump*(float)i;
    }
    return values;
}
@end
