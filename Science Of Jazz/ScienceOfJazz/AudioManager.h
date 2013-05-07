//
//  AudioManager.h
//  spektrum
//
//  Created by Garth Griffin on 3/23/10.
//  Copyright Garth Griffin 2010. 
//

/*
 PLEASE READ 
 Compiling for iPhone arm6 architecture:
 Since this uses a lot of floating point operations for the FFT, the iphone cpu will perform
 extremely poorly with default compilation settings. You should turn OFF the "compile for thumb"
 option under Target Info -> Build.
 */


#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioManager : NSObject {
	float* audioData;
	int audioLen;
	float* spectrumData;
	int spectrumLen;
	
	BOOL computeSpectrum;
	
	int errorStatus;
}

-(void)initializeAudioUnit;
-(void)startAudioUnit;
-(void)stopAudioUnit;
-(void)getAudioFrame;
-(BOOL)testGettingAudio;

@property float* audioData;
@property int audioLen;
@property float* spectrumData;
@property int spectrumLen;
@property BOOL computeSpectrum;
@property int errorStatus;

void analysisBuffersAlloc(int length);
void setBufferLens(int length);
void analysisBuffersReAlloc(int length);
void analysisBuffersFree();
void rioInterruptionListener(void *inClientData, UInt32 inInterruption);
void checkStatus(OSStatus s);

@end

