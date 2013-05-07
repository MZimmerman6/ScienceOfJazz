/*
 *  utils.cpp
 *  spektrum
 *
 *  Created by default on 4/8/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "utils.h"

/* linearInterp: does linear interpolation
 *  src: array containing original data
 *  dest: array to store output data
 *  origLen: original length of the data
 *  targLen: desired length of output data
 *
 * This function cannot necessarily be run in-place. If targLen is
 * greater than origLen, then origLen would be overwritten faster than
 * targLen was calculated.
 */
void linearInterp(float *src, float* dest, int origLen, int targLen) {
	
    if (origLen == targLen) {
        for (int i=0; i<targLen; i++) dest[i] = src[i];
        return;
    }
	
    float deltaY, frac, output;
    int x;
	
    for (int i=0; i<targLen; i++) {
        frac = (float)(i*origLen)/(float)targLen;
        x = (int)frac;
        frac -= x;
        if (x+1 >= origLen) deltaY = src[x] - src[x-1];
        else deltaY = src[x+1] - src[x];
        output = deltaY*frac + src[x];
        
        if (output > 1) output = 1;
        if (output < -1) output = -1;
        dest[i] = output;
        
    }
}