//
//  Localization.m
//  ScienceOfJazz
//
//  Created by ExCITe on 4/12/13.
//
//

#import "Localization.h"
#import "IntFunctions.h"
#import "FloatFunctions.h"
#import "AudioFunctions.h"
#import "AppDelegate.h"

#define kSpeedSound 13397.2441
#define kXStepSize 36
#define kYStepSize 36
#define kZStepSize 36

@implementation Localization


-(id) init {
    
    self = [super init];
    if (self) {
        numSpeakers = 4;
        sx = (int*)calloc(numSpeakers, sizeof(int));
        sy = (int*)calloc(numSpeakers, sizeof(int));
        sz = (int*)calloc(numSpeakers, sizeof(int));
        c = kSpeedSound;
        
        xStepSize = kXStepSize;
        yStepSize = kYStepSize;
        zStepSize = kZStepSize;
        
//        Speaker Defitions
//        *** Will be loaded from server later
        
//        Front Left
        sx[0] = 0;
        sy[0] = 772;
        sz[0] = 120;
    
//        Front Right
        sx[1] = 516;
        sy[1] = 772;
        sz[1] = 120;
        
//        Back Right
        sx[2] = 419;
        sy[2] = 0;
        sz[2] = 120;
        
//        Back Left
        sx[3] = 97;
        sy[3] = 0;
        sz[3] = 120;
        
        frequencies = (float*)calloc(numSpeakers, sizeof(float));
        frequencies[0] = 440;
        frequencies[1] = 880;
        frequencies[2] = 1760;
        frequencies[3] = 3520;
        
        freqLowerBounds = (int*)calloc(numSpeakers, sizeof(int));
        freqUpperBounds = (int*)calloc(numSpeakers, sizeof(int));
        
        timeBetweenSpeakers = 1.0;
        hopSize = 32;
        fftSize = 1024;
        percTimeWait = 0.5;
        buffs2wait = ((kInputSampleRate/fftSize)*timeBetweenSpeakers)*percTimeWait;
        
        magnitudePower = 2;
        hammingPower = 2;
        
        [self precomputeGrid];
        float *delayVals = (float*)calloc(numSpeakers, sizeof(float));
        
        delayVals[0] = 0.0136961451247165 ;
        delayVals[1] = -0.00952380952380949;
        delayVals[2] = -0.0109750566893423;
        delayVals[3] = 0.00734693877551029;
        float *coordinates = [self findBestMatchInGrid:delayVals];
        NSLog(@"(%f,%f,%f)",coordinates[0],coordinates[1],coordinates[2]);
        
        delays = (float*)calloc(1, sizeof(float));
        
        fft = [[AccelFFT alloc] init];
        [fft fftSetSize:fftSize];
        
        fftMag = (float*)calloc(fftSize/2.0, sizeof(float));
        fftPhase = (float*)calloc(fftSize/2.0, sizeof(float));
        
        nextFreq = 0;
        bufferPad = 2;
        circBuff = [[CircularBuffer alloc] initWithSize:kInputNumSamples*(2*bufferPad+1)];
        numThroughCircBuffer = 0;
        sampleStart = 0;
        
        occurrences = [[NSMutableArray alloc] init];
        occurrenceSpeaker = [[NSMutableArray alloc] init];
        
        free(delayVals);
        free(coordinates);
        
    }
    return self;
}


-(void) precomputeGrid {
    
//    clock_t start = clock();
    minX = [IntFunctions min:sx start:0 end:numSpeakers-1];
    maxX = [IntFunctions max:sx start:0 end:numSpeakers-1];
    
    minY = [IntFunctions min:sy start:0 end:numSpeakers-1];
    maxY = [IntFunctions max:sy start:0 end:numSpeakers-1];
    
    maxZ = [IntFunctions max:sz start:0 end:numSpeakers-1];
    
    xrange = maxX - minX;
    yrange = maxY - minY;
    zrange = maxZ;
    
    roomDimensions = CGPointMake(xrange, yrange);
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate updateRoomDimensions:roomDimensions];
    
    numX = (int)ceilf((float)xrange/xStepSize);
    numY = (int)ceilf((float)yrange/yStepSize);
    numZ = (int)ceilf((float)zrange/zStepSize);
    
    free(delays);
    
    dists = (float*)calloc(numX*numY*numZ*(numSpeakers+1), sizeof(float));
    delays = (float*)calloc(numX*numY*numZ*numSpeakers, sizeof(float));
    
    NSLog(@"Num Points = %i",numX*numY*numZ*(numSpeakers+1));
    
    xValues = [FloatFunctions linspace:minX end:maxX numElements:numX];
    yValues = [FloatFunctions linspace:minY end:maxY numElements:numY];
    zValues = [FloatFunctions linspace:0 end:maxZ numElements:numZ];
    
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    int index,i,j,k,s,tempS = 0;
    float xDist,yDist = 0;
    for (s = 0;s<=numSpeakers;s++) {
        for (i = 0;i<numX;i++){
            xDist = powf(xValues[i]-sx[s],2.0);
            for (j = 0;j<numY;j++) {
                yDist = powf(yValues[j]-sy[s],2.0);
                for (k = 0;k<numZ;k++) {
                    if (s == numSpeakers) {
                        tempS = 0;
                        xDist = powf(xValues[i]-sx[tempS],2.0);
                        yDist = powf(yValues[j]-sy[tempS],2.0);
                        index = (i*numY*numZ + j*numZ + k)*(numSpeakers+1) + s;
                        dists[index] = sqrtf(xDist + yDist + powf(zValues[k]-sz[tempS], 2));
                    } else {
                        index = (i*numY*numZ + j*numZ + k)*(numSpeakers+1) + s;
                        dists[index] = sqrtf(xDist + yDist + powf(zValues[k]-sz[s], 2));
                    }
                }
            }
        }
    }
    
    
    int nextSpeaker,currentSpeaker = 0;
    
    for (i = 0;i<numX;i++) {
        for (j=0;j<numY;j++) {
            for (k = 0;k<numZ;k++) {
                for (s = 0;s<numSpeakers;s++) {
                    currentSpeaker = (i*numY*numZ + j*numZ + k)*(numSpeakers+1) + s;
                    nextSpeaker = (i*numY*numZ + j*numZ + k)*(numSpeakers+1) + s+1;
                    index = (i*numY*numZ + j*numZ + k)*numSpeakers + s;
                    delays[index] = (dists[nextSpeaker] - dists[currentSpeaker])/kSpeedSound;
                }
            }
        }
    }
    
    free(dists);
    
    NSLog(@"done precomputing");
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    NSLog(@"precomputation time = %f", after - before);
    
}

-(float*) findBestMatchInGrid:(float *)delayVals {
    
    CFAbsoluteTime before = CFAbsoluteTimeGetCurrent();
    float minDistance = MAXFLOAT;
    float *minIndices = (float*)calloc(3, sizeof(float));
    float distance = 0;
    
    int i,j,k,s,index = 0;
    
    for (i = 0;i<numX;i++) {
        for (j = 0;j<numY;j++){
            for (k = 0;k<numZ;k++) {
                distance = 0;
                for (s = 0;s<numSpeakers;s++) {
                    index = (i*numY*numZ + j*numZ + k)*numSpeakers + s;
                    distance += powf(delayVals[s]-delays[index],2.0);
                }
                distance = sqrtf(distance);
                if (distance <= minDistance) {
                    minDistance = distance;
                    minIndices[0] = xValues[i];
                    minIndices[1] = yValues[j];
                    minIndices[2] = zValues[k];
                }
            }
        }
    }
    
    CFAbsoluteTime after = CFAbsoluteTimeGetCurrent();
    NSLog(@"search time = %f", after - before);
    
    return minIndices;
}

-(void) updateLocalizationInformation:(NSDictionary*)parameters {
    
    
//    NSLog(@"%@",parameters);
    numSpeakers = [[parameters objectForKey:@"numSpeakers"] intValue];
    
    free(sx);
    free(sy);
    free(sz);

    sx = (int*)calloc(numSpeakers, sizeof(int));
    sy = (int*)calloc(numSpeakers, sizeof(int));
    sz = (int*)calloc(numSpeakers, sizeof(int));
    
    NSArray *speakerX = [[parameters objectForKey:@"sx"] componentsSeparatedByString:@","];
    NSArray *speakerY = [[parameters objectForKey:@"sy"] componentsSeparatedByString:@","];
    NSArray *speakerZ = [[parameters objectForKey:@"sz"] componentsSeparatedByString:@","];
    NSArray *freqs = [[parameters objectForKey:@"frequencies"] componentsSeparatedByString:@","];
    
    for (int i = 0;i<numSpeakers;i++) {
        sx[i] = [[speakerX objectAtIndex:i] intValue];
        sy[i] = [[speakerY objectAtIndex:i] intValue];
        sz[i] = [[speakerZ objectAtIndex:i] intValue];
        frequencies[i] = [[freqs objectAtIndex:i] floatValue];
    }
    
    xStepSize = [[parameters objectForKey:@"xStep"] intValue];
    yStepSize = [[parameters objectForKey:@"yStep"] intValue];
    zStepSize = [[parameters objectForKey:@"zStep"] intValue];
    
    timeBetweenSpeakers = [[parameters objectForKey:@"timeDelay"] floatValue];
    
    hopSize = [[parameters objectForKey:@"stepsize"] intValue];
    fftSize = [[parameters objectForKey:@"fftsize"] intValue];
    
    
    percTimeWait = [[parameters objectForKey:@"percTimeWait"] floatValue];
    bufferPad = [[parameters objectForKey:@"bufferPadding"] intValue];
    
    circBuff = [[CircularBuffer alloc] initWithSize:kInputNumSamples*(bufferPad*2+1)];
    numThroughCircBuffer = 0;
    
    buffs2wait = ((kInputSampleRate/fftSize)*timeBetweenSpeakers)/2.0;
    
    magnitudePower = [[parameters objectForKey:@"fftmagOrder"] floatValue];
    hammingPower =[[parameters objectForKey:@"hammingOrder"] floatValue];
    
    spectralPercentage = [[parameters objectForKey:@"specPerc"] floatValue];
    powerPercentage = [[parameters objectForKey:@"percpower"] floatValue];
    
    NSString *runTemp = [parameters objectForKey:@"running"];
    if ([runTemp caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        running = YES;
    } else {
        running = NO;
    }
    
    [fft fftSetSize:fftSize];
    free(fftMag);
    free(fftPhase);
    fftMag = (float*)calloc(fftSize/2.0, sizeof(float));
    fftPhase = (float*)calloc(fftSize/2.0, sizeof(float));
    
    free(freqUpperBounds);
    free(freqLowerBounds);
    freqLowerBounds = (int*)calloc(numSpeakers, sizeof(int));
    freqUpperBounds = (int*)calloc(numSpeakers, sizeof(int));
    
    float linJump = (kInputSampleRate/2.0)/(fftSize/2.0+1);
    float freq;
    for (int i = 0;i<numSpeakers;i++) {
        freq = frequencies[i];
        freqLowerBounds[i] = (int)roundf(freq*(1-spectralPercentage/2.0)/linJump);
        if (freqLowerBounds[i] < 0) {
            freqLowerBounds[i] = 0;
        }
        freqUpperBounds[i] = (int)roundf(freq*(1+spectralPercentage/2.0)/linJump);
        if (freqUpperBounds[i] > (fftSize/2.0-1)) {
            freqUpperBounds[i] = (int)roundf(fftSize/2.0-1.0);
        }
    }
    occurrences = [[NSMutableArray alloc] init];
    occurrenceSpeaker = [[NSMutableArray alloc] init];
    [self precomputeGrid];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate startAudioInput];
    
}

-(void) analyzeBuffer:(float *)buffer startSample:(int)startVal bufferLength:(int)length {
    
    [circBuff pushToBuffer:buffer numSamples:length];
    numThroughCircBuffer++;
    
    if (buffs2wait <= buffswaited && numThroughCircBuffer >= bufferPad) {
        float *hamming = [AudioFunctions hamming:length power:hammingPower];
        for (int i = 0;i<length;i++) {
            hamming[i] = hamming[i]*buffer[i];
        }
        
        memset(fftMag, 0, (int)(fftSize/2.0));
        memset(fftPhase, 0, (int)(fftSize/2.0));
        [fft forwardWithStart:0 withBuffer:hamming magnitude:fftMag phase:fftPhase useWindow:NO bufferSize:length];
        
        float max = 0;
        vDSP_Length index = 0;
        vDSP_maxvi(fftMag, 1, &max, &index, (int)floorf(fftSize/2.0));
    //    NSLog(@"%i",(int)index);
        int idx = (int)index;
        
        
        int i,j,minIndex,maxIndex;
        float specPower = 0;
        for (i = 0;i<(fftSize/2.0);i++) {
            specPower += powf(powf(fftMag[i], magnitudePower),2.0);
        }
        float freqPower = 0;
        
        
    //    if no previous speaker was heard, try to find the first
        if (nextFreq == -1) {
            for (i = 0 ;i<numSpeakers;i++) {
                minIndex = freqLowerBounds[i];
                maxIndex = freqUpperBounds[i];
                if (idx >= minIndex && idx <= maxIndex) {
                    freqPower = 0;
                    for (j = minIndex;j<=maxIndex;j++) {
                        freqPower += powf(powf(fftMag[j],magnitudePower),2.0);
                    }
                    if (freqPower/specPower >= spectralPercentage) {
                        NSLog(@"Found Frequency - %f",frequencies[i]);
                        buffswaited = 0;
                        matchedFrequency = i;
                        nextFreq = (int)fmodf(i+1, numSpeakers);
                        foundMatch = YES;
                    }
                    break;
                }
            }
        } else {
            minIndex = freqLowerBounds[nextFreq];
            maxIndex = freqUpperBounds[nextFreq];
            if (idx >= minIndex && idx <= maxIndex) {
                freqPower = 0;
                for (j = minIndex;j<=maxIndex;j++) {
                    freqPower += powf(powf(fftMag[j],magnitudePower),2.0);
                }
                if (freqPower/specPower >= spectralPercentage) {
                    NSLog(@"Found Frequency - %f",frequencies[nextFreq]);
                    buffswaited = 0;
                    matchedFrequency = nextFreq;
                    nextFreq = (int)fmodf(nextFreq+1, numSpeakers);
                    foundMatch = YES;
                }
            }
        }
        free(hamming);
    } else {
        buffswaited++;
    }
    
    if (foundMatch && buffswaited == bufferPad) {
        
        onsetStart = sampleStart;
        onsetFreq = matchedFrequency;
        onsetArray = [circBuff getBufferCopy];
        [NSThread detachNewThreadSelector:@selector(findOnset) toTarget:self withObject:nil];
        foundMatch = NO;
    }
    sampleStart += kInputNumSamples;
}

-(void) findFrequencyOnset:(float *)buffer startSample:(int)startVal freqVal:(int)freq {
}

-(void) findOnset {

    
    float *tempArray = (float*)calloc(kInputNumSamples, sizeof(float));
    float *hamming = [AudioFunctions hamming:kInputNumSamples power:hammingPower];
    float *mag = (float*)calloc(fftSize/2.0, sizeof(float));
    float *phase = (float*)calloc(fftSize/2.0, sizeof(float));
    
    
    int startPoint = 0;
    int i,j,count;
    int minIndex = freqLowerBounds[onsetFreq];
    int maxIndex = freqUpperBounds[onsetFreq];
    float specPower,freqPower;
    int foundStart = 0;
    
    while (startPoint < kInputNumSamples*(bufferPad*2+1)-fftSize) {
        count = 0;
        for (i = startPoint;i<startPoint+fftSize;i++) {
            tempArray[count] = onsetArray[i]*hamming[count];
            count++;
        }
        memset(mag, 0, fftSize/2.0);
        memset(phase, 0, fftSize/2.0);
        [fft forwardWithStart:0 withBuffer:tempArray magnitude:mag phase:phase useWindow:NO bufferSize:kInputNumSamples];
        startPoint += hopSize;
        
        specPower = 0;
        for (i = 0;i<(fftSize/2.0);i++) {
            specPower += powf(powf(mag[i], magnitudePower),2.0);
        }
        freqPower = 0;
        for (j = minIndex;j<=maxIndex;j++) {
            freqPower += powf(powf(mag[j],magnitudePower),2.0);
        }
        if (freqPower/specPower >= spectralPercentage) {
            foundStart = startPoint;
            break;
        }
    }
    foundStart += onsetStart;
    
    [occurrences addObject:[NSNumber numberWithInt:foundStart]];
    [occurrenceSpeaker addObject:[NSNumber numberWithInt:onsetFreq]];
    
    if ([occurrences count] == numSpeakers+1) {
        float first,second;
        float *delayVals = (float*)calloc(numSpeakers, sizeof(float));
        for (int i = 0;i<numSpeakers;i++) {
            first = [[occurrences objectAtIndex:i] floatValue]/kInputSampleRate-i*timeBetweenSpeakers;
            second = [[occurrences objectAtIndex:(i+1)] floatValue]/kInputSampleRate-(i+1)*timeBetweenSpeakers;
            delayVals[i] = second-first;
        }
        float *coordinates = [self findBestMatchInGrid:delayVals];
        coordinates[0] = coordinates[0]/320;
        coordinates[1] = coordinates[1]/416;
        CGPoint location = CGPointMake(coordinates[0], coordinates[1]);
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate updateUserLocation:location];
    }

    NSLog(@"%i - %i",onsetStart,foundStart);
    free(mag);
    free(phase);
    free(hamming);
    free(tempArray);
}

@end
