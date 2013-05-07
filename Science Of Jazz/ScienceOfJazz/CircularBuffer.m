//
//  CircularBuffer.m
//  ScienceOfJazz
//
//  Created by Matthew Zimmerman on 4/19/13.
//
//

#import "CircularBuffer.h"

@implementation CircularBuffer



-(id) initWithSize:(int)buffSize {
    
    self = [super init];
    if (self) {
        circBuffer = (float*)calloc(buffSize, sizeof(float));
        bufferSampleStart = 0;
        bufferLength = buffSize;
    }
    return self;
}

-(void) pushToBuffer:(float *)buffer numSamples:(int)numSamples {
    
    if (numSamples > bufferLength) {
        NSLog(@"Trying to push too many samples onto buffer, not successful");
        return;
    }
    
    int offset = bufferLength-numSamples;
    int count=0,i = 0;
    for (i = numSamples;i<bufferLength;i++) {
        circBuffer[count] = circBuffer[i];
        count++;
    }
    
    count = 0;
    for (i = offset;i<bufferLength;i++) {
        circBuffer[i] = buffer[count];
        count++;
    }
    bufferSampleStart += numSamples;

    
}

// this function will lose all reference to the buffer once it is completed, so if used
// make sure you free the buffer once finished with it, or it will overflow.
-(float*) getBufferSamples:(int)numSamples {
    
    if (numSamples > bufferLength) {
        return NULL;
    }
    float *buff = (float*)calloc(numSamples, sizeof(float));
    
    for (int i = 0;i<numSamples;i++) {
        buff[i] = circBuffer[i];
    }
    return buff;
}

-(float*) getBufferCopy {
    float *copy = (float*)calloc(bufferLength, sizeof(float));
    for (int i = 0;i<bufferLength;i++) {
        copy[i] = circBuffer[i];
    }
    return copy;
}

-(int) getBufferLength {
    return bufferLength;
}


@end
