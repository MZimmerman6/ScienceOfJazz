//
//  GLViewController.h
//  Spectrum3D
//
//  Created by Garth Griffin on May 2010.
//  Copyright Garth Griffin 2010. 
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "Camera3D.h"
#import "AudioManager.h"
#import "AudioModel.h"
#import "OverlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MulticastClient.h"
#import "AppDelegate.h"
@interface GLViewController : UIViewController <GLViewDelegate>
{
	// audio manager
	AudioManager* audioManager;
	
	// audio model
	AudioModel pianoModel;
    AudioModel trumpetModel;
    AudioModel bassModel;
    AudioModel drumsModel;
    
	GLfloat* pianoModelBuffer;
    GLfloat* trumpetModelBuffer;
    GLfloat* bassModelBuffer;
	GLfloat* drumsModelBuffer;
	// overlay
	OverlayViewController* overlayViewController;
	
	// global camera variable
	Camera3D camera;
	
	// global values for handling touches
	CGFloat prevTouchDistance;
	CGPoint prevTouchPoint;
	float cameraYZTheta;
	float cameraYZRadius;
	float cameraXOffset;
    
    NSMutableArray* bassData;
    NSMutableArray* trumpetData;
    NSMutableArray* pianoData;
    NSMutableArray* drumsData;
    int pianoFrameCounter;
    int trumpetFrameCounter;
    AVAudioPlayer* audioPlayer;
    MulticastClient* client;
    
    BOOL specRunning;
    
}

float fZeroIfOverCeiling(float val, float ceiling);
float fCapToBounds(float val, float min, float max);

-(void) stopSpectrum;

-(void) startSpectrum;

@end
