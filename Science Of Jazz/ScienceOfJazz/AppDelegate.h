//
//  AppDelegate.h
//  ScienceOfJazz
//
//  Created by Matthew Zimmerman on 3/29/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MulticastServer.h"
#import "MulticastClient.h"
#import "SoundFieldViewController.h"
#import "SOMViewController.h"
#import "AudioInput.h"
#import "AccelFFT.h"
#import "TakeOverViewController.h"
#import "Localization.h"
#import "CircularBuffer.h"

@class SOMViewController;
@class SoundFieldViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, AudioInputDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    MulticastClient* client;
    MulticastServer* server;
    SoundFieldViewController *soundField;
    BOOL somLoaded;
    BOOL appSleptAfterSOM;
    
    AudioInput *audioIn;
    
    NSTimer *updateTimer;
    
    NSMutableDictionary *chromaInfo;
    NSMutableDictionary *localizationInfo;
    NSMutableDictionary *audioInfo;
    NSMutableDictionary *spectrumInfo;
    NSMutableDictionary *soundFieldInfo;
    
    NSURL *spectrumURL;
    NSURL *chromaURL;
    NSURL *localizationURL;
    NSURL *audioURL;
    NSURL *soundFieldURL;
    
    NSURLRequest *chromaRequest;
    NSURLRequest *localizationRequest;
    NSURLRequest *audioRequest;
    NSURLRequest *spectrumRequest;
    NSURLRequest *soundFieldRequest;
    
    NSURLConnection *chromaConnection;
    NSURLConnection *localizationConnection;
    NSURLConnection *audioConnection;
    NSURLConnection *spectrumConnection;
    NSURLConnection *soundFieldConnection;
    
    NSMutableData *chromaData;
    NSMutableData *audioData;
    NSMutableData *spectrumData;
    NSMutableData *localizationData;
    NSMutableData *soundFieldData;
    
    
    
    BOOL chromaUpdating;
    BOOL spectrumUpdating;
    BOOL localizationUpdating;
    BOOL audioUpdating;
    BOOL soundFieldUpdating;
    
    AccelFFT *fft;
    float *audioBuffer;
    float *fillBuffer;
    int currentSample;
    
    int fftSize;
    
    
    float* fftMag;
    float* fftPhase;
    float* complexBuffer;
    
    float signalPower;
    
    BOOL takenOver;
    
    NSURL *imageURL;
    UIImage *soundFieldBackground;
    NSMutableData *imageData;
    NSURLConnection *imageConnection;
    NSURLRequest *imageRequest;
    BOOL imageUpdating;
    
    NSTimer *takeOverCheckTimer;
    NSTimer *takeOverUpdateTimer;
    NSTimer *highlightTimer;
    
    NSTimer *localizationTakeoverTimer;
    
    Localization *local;
    
    CGPoint userLocation;
    CGPoint roomDimensions;
    
    int buffIndex;
    
    
    BOOL localTakeoverActive;
    
//    UIView *controlOverlay;
}

-(void)setupMulticast;
//-(void)setSOMActivated:(BOOL)status;
-(void)restartMulticastAfterSocketClose;

@property BOOL somLoaded;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SOMViewController *welcome;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MulticastClient* client;
@property (strong, nonatomic) MulticastServer* server;
@property (strong, nonatomic) SoundFieldViewController *soundField;
@property (strong, nonatomic) TakeOverViewController *takeOver;

@property (strong, nonatomic) UIView *controlOverlay;

-(void) updateFromServers;

-(void) processAndUpdateChroma;

-(void) processAndUpdateLocalization;

-(void) processAndUpdateSpectrum;

-(void) processAndUpdateAudio;

-(void) processAndUpdateSoundField;

-(void) checkTakeOver;

-(void) processAndUpdateSoundFieldBackground;

-(void) setLocation:(CGPoint)point;

-(void) removeControlView;

-(void) updateTakeOverView;

-(void) updateRoomDimensions:(CGPoint)dimensions;

-(void) updateUserLocation:(CGPoint)location;

-(void) startAudioInput;

-(float) checkLocationHighlight;

-(void) checkLocalizationTakeover;

 @end
