//
//  Localization.h
//  ScienceOfJazz
//
//  Created by ExCITe on 4/12/13.
//
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "AccelFFT.h"
#import "CircularBuffer.h"

@interface Localization : NSObject {
    
    int numX;
    int numY;
    int numZ;
    
    int minX;
    int minY;
    int minZ;
    
    int maxX;
    int maxY;
    int maxZ;
    
    
    int xrange;
    int yrange;
    int zrange;
    
    int c;
    
    int* sx;
    int* sy;
    int* sz;
    int numSpeakers;
    
    float* xValues;
    float* yValues;
    float* zValues;
    
    float* dists;
    float* delays;
    
    
    int xStepSize;
    int yStepSize;
    int zStepSize;
    
    CGPoint roomDimensions;
    
    float *frequencies;
    
    float timeBetweenSpeakers;
    
    int hopSize;
    int fftSize;
    
    float magnitudePower;
    float hammingPower;
    
    float spectralPercentage;
    float powerPercentage;
    
    BOOL running;
    
    float* fftMag;
    float* fftPhase;
    
    AccelFFT *fft;
    int buildUpStart;
    
    int *freqUpperBounds;
    int *freqLowerBounds;
    int buffercount;
    int nextFreq;
    
    int buffs2wait;
    int buffswaited;
    
    float percTimeWait;
    int bufferPad;
    
    int numThroughCircBuffer;
    
    CircularBuffer *circBuff;
    BOOL foundMatch;
    int matchedFrequency;
    
    int sampleStart;
    
    int onsetStart;
    int onsetFreq;
    float *onsetArray;
    
    float *occurances;
    
    NSMutableArray *occurrences;
    NSMutableArray *occurrenceSpeaker;
    
}

-(void) precomputeGrid;

-(float*) findBestMatchInGrid:(float*)delayVals;

-(void) updateLocalizationInformation:(NSDictionary*)parameters;

-(void) analyzeBuffer:(float*)buffer startSample:(int)startVal bufferLength:(int)length;

-(void) findFrequencyOnset:(float*)buffer startSample:(int)startVal freqVal:(int)freq;


@end
