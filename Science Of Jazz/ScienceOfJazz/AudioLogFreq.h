/*
 *  AudioLogFreq.h
 *  Spectrum3D
 *
 *  Created by default on 6/14/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */


void convertToLogScale(float* inData, 
					   int inLen, 
					   float* outData, 
					   int outLen, 
					   float minFreq, 
					   float maxFreq);

void oldConvertToLogFreq(float frac, int numBins, float* inMagSpec, int length, float* outLogMagSpec);

float calcLogFreqFraction(int inputLength, int numBins);