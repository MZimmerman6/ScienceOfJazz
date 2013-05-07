//
//  SoundFieldViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundBlob.h"
#import "UserBlobs.h"
#import "MulticastClient.h"
#import "MulticastServer.h"
#import "AppDelegate.h"
#import "SoundFieldInfoViewController.h"
@interface SoundFieldViewController : UIViewController <UIActionSheetDelegate,AVAudioRecorderDelegate> {
    
    NSMutableDictionary* blobXDictionary;
    
    // Debug, remove
    NSTimer* updateTimer;
    NSMutableArray* blobList;
    UIActionSheet *optionsAction;
    UIToolbar *bottomBar;
    BOOL choseLocationEnabled;
    CGPoint userLocation;
    UIImageView *userImage;
    UserBlobs *user;
    AVAudioRecorder *recorder;
    NSTimer *powerTimer;
    float powerValue;
    
    MulticastServer* server;
    MulticastClient* client;
    NSString* ipAddress;
    BOOL locationChosen;
    BOOL gotIP;
    BOOL appSleeping;
    BOOL measurementsStarted;
    
    SoundFieldInfoViewController *soundfieldInfo;
    
    
    int iPhone5XOffset;
    int iPhone5YOffset;
    int iPhoneXOffset;
    int iPhoneYOffset;
    
    int scaleFactor;
    
    IBOutlet UIImageView *backgroundImage;
    
//    IBOutlet UIView *overlayView;
}

@property int overlayShift;
@property int powerScaling;
@property (nonatomic, strong) IBOutlet UIView *overlayView;

-(void) setAudioPower:(float)power;

- (UserBlobs*)addUserBlob:(int)newX y:(int)newY;

-(IBAction)backPressed:(id)sender;

-(IBAction)locatePressed:(id)sender;

-(void) soundFieldAppSleeping;

-(void) soundFieldAppUnSleep;

//-(void)optionsPressed;

-(BOOL) startMeasurement;

-(BOOL) stopEchoLocation;

-(void) sendPowerValue;

-(void) updateUserIntensity;

-(void) doPowerStuff;

-(void) enableLocationChoosing;

-(void) setupAudioRecording;

- (NSString *)getIPAddress;

-(void) infoPressed;

-(void) updateBackgroundImage:(UIImage*)image;

-(void) updateSoundFieldOverlayShift:(int)shift andScaling:(int)scaling;

-(void) shiftOverlay;

-(void) updateUserBlob:(CGPoint)location;

@end
