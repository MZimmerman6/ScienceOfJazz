/*
 *  AudioLogFreq.cpp
 *  Spectrum3D
 *
 *  Created by default on 6/14/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "AudioLogFreq.h"

 // converts to logarithmic frequency bins.
 // only the last log[frac](length) bins will have nonzero values
 void oldConvertToLogFreq(float frac, int numBins, float* inMagSpec, int length, float* outLogMagSpec) {
	 
	 int maxIndex = length;
	 int minIndex = (int)(length/frac);
	 int binWidth;
	 float avg;
	 
	 for (int i=numBins-1; i>=0; i--) {
		 avg = 0;
		 for (int j=minIndex; j<maxIndex; j++) {
			 avg += inMagSpec[j];
		 }
		 binWidth = maxIndex-minIndex;
		 if (binWidth > 0)
			 outLogMagSpec[i] = avg/(float)binWidth;
		 else
			 outLogMagSpec[i] = 0.0f;
		 
		 maxIndex = minIndex;
		 minIndex = (int)((float)minIndex/frac);
	 }
 }

 // TODO: this function sucks right now
float calcLogFreqFraction(int inputLength, int numBins) {
	return 1.1f;
	//return 2.0f;
}

void convertToLogScale(float* inData, 
					   int inLen, 
					   float* outData, 
					   int outLen, 
					   float minFreq, 
					   float maxFreq)
{
	
	for (int i=0; i<outLen; i++) {
		outData[i] = inData[i];
	}
	
	//oldConvertToLogFreq(2.0f, outLen, inData, inLen, outData);
}