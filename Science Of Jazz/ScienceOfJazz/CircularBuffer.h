//
//  CircularBuffer.h
//  ScienceOfJazz
//
//  Created by Matthew Zimmerman on 4/19/13.
//
//

#import <Foundation/Foundation.h>

@interface CircularBuffer : NSObject {
    
    
    float *circBuffer;
    int bufferLength;
    int bufferSampleStart;
    
}

-(id) initWithSize:(int)buffSize;

-(void) pushToBuffer:(float*)buffer numSamples:(int)numSamples;

-(float*) getBufferSamples:(int)numSamples;

-(float*) getBufferCopy;

-(int) getBufferLength;

@end
