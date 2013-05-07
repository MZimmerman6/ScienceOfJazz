//
//  GLViewController.m
//  Spectrum3D
//
//  Created by Garth Griffin on May 2010.
//  Copyright Garth Griffin 2010. 
//

#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"
#import "AudioLogFreq.h"
#include "utils.h"
#import "AppDelegate.h"

// use lighting?
#define SETUP_LIGHTING 0

// use textures?
#define SETUP_TEXTURE 0
#define NUM_TEXTURES 1
GLuint textures[NUM_TEXTURES];

// print touch locations?
#define DEBUG_TOUCH_LOCATIONS 0

/****************************************************************************************/
/*
 Constants for drawing.
 */

// initial camera position
static const GLfloat initialCameraYZTheta = .1*M_PI;
static const GLfloat cameraYOffset = 0.0f;
static const GLfloat cameraZOffset = -2.0f;

// audio model x-axis
//	This is the resolution of the audio model x-axis.
//	More points means it looks nice (especially at higher frequencies),
//	but more points also requires more cpu.
//	IMPORTANT: 2*(z-1) + z*x + x < 35535 or GL dies.
static const GLuint audioModelXDataLen = 32;

// audio model z-axis
//	This is the number of z-axis frames to store.
//	IMPORTANT: 2*(z-1) + z*x + x < 35535 or GL dies.
static const GLuint audioModelZDataLen = 75;

// audio model initial dimensions in virtual space
static const GLfloat audioModelInitLength = 6.0f;
static const GLfloat audioModelInitWidth = 3.0f;
static const GLfloat audioModelInitHeight = 1.0f;

// background
static const GLfloat backgroundColor[] = {0.0f, 0.0f, 0.0f, 1.0f};

// touches
static const float scaleTwoTouchDist = .01f;
static const float scaleOneTouchX = -.005f;
static const float scaleOneTouchY = .01f;


/****************************************************************************************/
/*
 Class implementation
 */
@implementation GLViewController

/***********************************************************************/
// drawing functions: frame


-(void) audioModelRenderFrame {
	AudioModelAddXData(&pianoModel, pianoModelBuffer, 0);
	AudioModelAddXData(&trumpetModel, trumpetModelBuffer, 1);
	AudioModelAddXData(&bassModel, bassModelBuffer, 2);
	AudioModelAddXData(&drumsModel, drumsModelBuffer, 3);
}


-(void) glViewRenderFrame {
	glLoadIdentity();
	
	glClearColor(backgroundColor[0], backgroundColor[1], backgroundColor[2], backgroundColor[3]);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// enable required modes
	glEnableClientState(GL_VERTEX_ARRAY);			// use with glVertexPointer
	glEnableClientState(GL_COLOR_ARRAY);			// use with "glColorPointer"
	
	// move camera
	Camera3DLookAt(camera);
	
	glVertexPointer(3, GL_FLOAT, 0, pianoModel.vertices);
	glColorPointer(4, GL_FLOAT, 0, pianoModel.colors);
	AudioModelDrawElements(&pianoModel);

	glVertexPointer(3, GL_FLOAT, 0, trumpetModel.vertices);
	glColorPointer(4, GL_FLOAT, 0, trumpetModel.colors);
	AudioModelDrawElements(&trumpetModel);
	
	glVertexPointer(3, GL_FLOAT, 0, bassModel.vertices);
	glColorPointer(4, GL_FLOAT, 0, bassModel.colors);
	AudioModelDrawElements(&bassModel);
	
	glVertexPointer(3, GL_FLOAT, 0, drumsModel.vertices);
	glColorPointer(4, GL_FLOAT, 0, drumsModel.colors);
	AudioModelDrawElements(&drumsModel);
	
	// disable required modes
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


- (void)drawView:(UIView *)theView {
	[self audioModelRenderFrame];
	[self glViewRenderFrame];
	[overlayViewController renderFrame];
}


/***********************************************************************/
// drawing functions: setup


-(void) audioModelSetup {
	// make audio model
	pianoModel = AudioModelMake(audioModelXDataLen, audioModelZDataLen);
	AudioModelSetDimensions(&pianoModel, 
							audioModelInitLength, 
							audioModelInitWidth, 
							audioModelInitHeight);
	
	trumpetModel = AudioModelMake(audioModelXDataLen, audioModelZDataLen);
	AudioModelSetDimensions(&trumpetModel, 
							audioModelInitLength, 
							audioModelInitWidth, 
							audioModelInitHeight);
	
	bassModel = AudioModelMake(audioModelXDataLen, audioModelZDataLen);
	AudioModelSetDimensions(&bassModel, 
							audioModelInitLength, 
							audioModelInitWidth, 
							audioModelInitHeight);
	
	
	
	drumsModel = AudioModelMake(audioModelXDataLen, audioModelZDataLen);
	AudioModelSetDimensions(&drumsModel, 
							audioModelInitLength, 
							audioModelInitWidth, 
							audioModelInitHeight);
	

	pianoModelBuffer = (GLfloat*)malloc(sizeof(GLfloat)*audioModelXDataLen);
	trumpetModelBuffer = (GLfloat*)malloc(sizeof(GLfloat)*audioModelXDataLen);
	bassModelBuffer = (GLfloat*)malloc(sizeof(GLfloat)*audioModelXDataLen);
	drumsModelBuffer = (GLfloat*)malloc(sizeof(GLfloat)*audioModelXDataLen);
    NSLog(@"audio model setup");
}


-(void) glViewSetup:(GLView*)view {
	// viewport
	const GLfloat zNear = 0.01, zFar = 100.0, fieldOfView = 45.0; 
	GLfloat size; 
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION); 
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = view.bounds; 
	glFrustumf(-size, size, 
			   -size / (rect.size.width / rect.size.height), 
			   size / (rect.size.width / rect.size.height), 
			   zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
	
	// rotate to landscapeRight mode
	glRotatef(270.0f, 0.0f, 0.0f, 1.0f);
	
	// ensure subsequent xforms apply to model not view
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	// initialize camera
	cameraXOffset = 0.0f;
	Vertex3D cameraOrigin = {cameraXOffset, cameraYOffset, cameraZOffset};
	Vertex3D cameraEye = {cameraXOffset, cameraYOffset, -1*cameraZOffset};
	Vector3D cameraUp = {0.0, 1.0, 0.0};
	camera = Camera3DMake(cameraEye, cameraOrigin, cameraUp);
	cameraYZTheta = initialCameraYZTheta;
	cameraYZRadius = fabs(camera.eye.z - camera.center.z);
	camera.eye.y = cameraYZRadius*sinf(cameraYZTheta)+cameraYOffset;
	camera.eye.z = cameraYZRadius*cosf(cameraYZTheta)+cameraZOffset;
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
#if SETUP_LIGHTING
	// setup lighting
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	const GLfloat light0Ambi[] = {0.0, 0.0, 0.0, 1.0};
	const GLfloat light0Diff[] = {0.3, 0.3, 0.3, 1.0};
	const GLfloat light0Spec[] = {0.7, 0.7, 0.7, 1.0};
	const GLfloat light0Position[] = {0.,32.,64.,0.};
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0Ambi);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diff);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0Spec);
	glLightfv(GL_LIGHT0, GL_POSITION, light0Position);
#endif
	
#if SETUP_TEXTURE
	// enable texturing
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	glGenTextures(NUM_TEXTURES, textures);
	
	// set up texture 0
	glBindTexture(GL_TEXTURE_2D, textures[0]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	// TODO: should change these to mipmaps!
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// created pvrtc file with texturetool defaults:
	// $ texturetool -e PVRTC -o texture.pvrtc texture.png
	NSString *tex0Path = [[NSBundle mainBundle] pathForResource:@"plantTexture" 
														 ofType:@"pvrtc"];
	NSData *tex0Data = [[NSData alloc] initWithContentsOfFile:tex0Path];
	glCompressedTexImage2D(GL_TEXTURE_2D, 0, 
						   GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, 
						   256, 256, 0, 
						   [tex0Data length], [tex0Data bytes]);
#endif
    NSLog(@"GL View Set up");
	
}


-(void) overlaySetup:(GLView*)theView {
	overlayViewController = [[OverlayViewController alloc] initWithFramerate:kRenderingFrequency];
	[theView addSubview:overlayViewController.view];
}

- (void)loadSpectralData {
    /*double pianoMax = 1.0;
	double trumpetMax = 1.0;
	double bassMax = 1.0;
    
    pianoData = [NSMutableArray new];
	trumpetData = [NSMutableArray new];
	bassData = [NSMutableArray new];
    
    NSStringEncoding encoding;
    NSError* error;
	
	// Load piano data
    NSString* pianoPath = [[NSBundle mainBundle] pathForResource:@"PianoSpec32Log" ofType:@"csv"];
    NSString* pianoVals = [NSString stringWithContentsOfFile:pianoPath usedEncoding:&encoding error:&error];
    NSArray* pianoLines = [pianoVals componentsSeparatedByString:@"\n"];
    for (int i=0; i<[pianoLines count]; i++) {
        NSArray* spectrum = [[pianoLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* specVals = [[NSMutableArray new] autorelease];
        for (int j=0; j<[spectrum count]; j++) {
            NSString* s = [spectrum objectAtIndex:j];
            if ([s doubleValue] > pianoMax) {
                pianoMax = [s doubleValue];
            }
            [specVals addObject:[NSNumber numberWithDouble:[s doubleValue]]];
        }
        
        [pianoData addObject:specVals];
    }
    for (int i=0; i<[pianoData count]; i++) {
        NSMutableArray* spectrum = [pianoData objectAtIndex:i];
        for (int j=0; j<[spectrum count]; j++) {
            double val = [[spectrum objectAtIndex:j] doubleValue]/(pianoMax);
            [spectrum replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
	
	// Load trumpet data
	NSString* trumpetPath = [[NSBundle mainBundle] pathForResource:@"TrumpetSpec32Log" ofType:@"csv"];
    NSString* trumpetVals = [NSString stringWithContentsOfFile:trumpetPath usedEncoding:&encoding error:&error];
    NSArray* trumpetLines = [trumpetVals componentsSeparatedByString:@"\n"];
    for (int i=0; i<[trumpetLines count]; i++) {
        NSArray* spectrum = [[trumpetLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* specVals = [[NSMutableArray new] autorelease];
        for (int j=0; j<[spectrum count]; j++) {
            NSString* s = [spectrum objectAtIndex:j];
            if ([s doubleValue] > trumpetMax) {
                trumpetMax = [s doubleValue];
            }
            [specVals addObject:[NSNumber numberWithDouble:[s doubleValue]]];
        }
        
        [trumpetData addObject:specVals];
    }
    for (int i=0; i<[trumpetData count]; i++) {
        NSMutableArray* spectrum = [trumpetData objectAtIndex:i];
        for (int j=0; j<[spectrum count]; j++) {
			// DOLHANSKY: Halving the trumpet max is just for demo purposes
            double val = [[spectrum objectAtIndex:j] doubleValue]/(trumpetMax*0.5);
            [spectrum replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
	
	// Load bass data
	NSString* bassPath = [[NSBundle mainBundle] pathForResource:@"BassSpec32Log" ofType:@"csv"];
    NSString* bassVals = [NSString stringWithContentsOfFile:bassPath usedEncoding:&encoding error:&error];
    NSArray* bassLines = [bassVals componentsSeparatedByString:@"\n"];
    for (int i=0; i<[bassLines count]; i++) {
        NSArray* spectrum = [[bassLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* specVals = [[NSMutableArray new] autorelease];
        for (int j=0; j<[spectrum count]; j++) {
            NSString* s = [spectrum objectAtIndex:j];
            if ([s doubleValue] > bassMax) {
                bassMax = [s doubleValue];
            }
            [specVals addObject:[NSNumber numberWithDouble:[s doubleValue]]];
        }
        
        [bassData addObject:specVals];
    }
    for (int i=0; i<[bassData count]; i++) {
        NSMutableArray* spectrum = [bassData objectAtIndex:i];
        for (int j=0; j<[spectrum count]; j++) {
			// DOLHANSKY: Halving the trumpet max is just for demo purposes
            double val = [[spectrum objectAtIndex:j] doubleValue]/(bassMax);
            [spectrum replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
    

	
    NSLog(@"Spectral data loaded.");
    */
	
    pianoFrameCounter = 8;
	trumpetFrameCounter = 8;
}





//////////////////////////////
//							//
//     CHange this shit		//
//							//
//////////////////////////////


- (void)updateSpectrum {
	if([client isSocketOpen] && specRunning)
    {
        NSData* buffer=[[NSData alloc] init];
        buffer = [client getCurrentData];
        
        ///////////////////////////
        //  NETWORK DATA FORMAT  //
        //////////////////////////////////////////////////////////////////////////
        //
//        NSRange tagRange = {0,4};           //tag = jawn                        //
//        NSRange cRange1 = {4,12};           //chroma Inst1                      //
//        NSRange cRange2 = {16,12};          //chroma Inst2                      //
//        NSRange cRange3 = {28,12};          //chroma Inst3                      //
//        NSRange cRange4 = {40,1};           //chroma Drums (just energy)        //	
//        //
//        NSRange fftRange1 = {41,32};        //fft Inst1 32 Points log spaced    //
//        NSRange fftRange2 = {73,32};        //fft Inst2 32 Points log spaced    //
//        NSRange fftRange3 = {105,32};       //fft Inst3 32 Points log spaced    //
//        NSRange fftRange4 = {137,32};       //fft Drums 32 Points log spaced    //
//        //
//        NSRange freqValsRange = {169,32};   //fft frequency vals                //
        //
        //////////////////////////////////////////////////////////////////////////
        
        
        if([buffer length]>200)
        {
            
            
            float* jawnbytes = (float *) malloc (sizeof(float) * 250);
            [buffer getBytes:jawnbytes];
			
            
            for (int i=0; i<audioModelXDataLen; i++) 
            {
                if (pianoFrameCounter >= 0) {
                    
                    trumpetModelBuffer[i]= jawnbytes[i+41];
                    pianoModelBuffer[i]	 = jawnbytes[i+41+32];
                    bassModelBuffer[i]	 = jawnbytes[i+41+32+32];
                    drumsModelBuffer[i]	 = jawnbytes[i+41+32+32+32];				
                    //drumsModelBuffer[i]	 = jawnbytes[i+41];
                    
                }
                else
                {
                    pianoModelBuffer[i] = 1.0;
                    bassModelBuffer[i] = 0.0;
                    trumpetModelBuffer[i] = 0.0;
                    drumsModelBuffer[i] = 0.0;
                }
            }
            
            
        } else {
            
            for (int i = 0;i<audioModelXDataLen;i++) {
                pianoModelBuffer[i] = arc4random()/RAND_MAX/1.5;
                bassModelBuffer[i] = arc4random()/RAND_MAX/1.5;
                trumpetModelBuffer[i] = arc4random()/RAND_MAX/1.5;
                drumsModelBuffer[i] = arc4random()/RAND_MAX/1.5;
            }
        }

    }
		
    pianoFrameCounter++;
	//MATT Comment [buffer release];
}

- (void)loadAudio {
   /* NSURL* url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/jazz.mp3", [[NSBundle mainBundle] resourcePath]]];
    
    NSError* error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer retain];
    audioPlayer.numberOfLoops = 1;
    
    if (audioPlayer == nil) {
        NSLog(@"%@", [error description]);
    } else {
        NSLog(@"Audio loaded.\n");
        audioPlayer.volume = 1.0;
    }*/
}

- (void)startAudioAndAnimation {
    [NSTimer scheduledTimerWithTimeInterval:1.0/16.0 target:self selector:@selector(updateSpectrum) userInfo:nil repeats:YES];
    //[audioPlayer play];
}


-(void)setupView:(GLView*)theView {
	[self glViewSetup:theView];
	[self audioModelSetup];
    //[self loadAudio];
//	[self overlaySetup:theView];
    //[self loadAudio];
  //  [self loadSpectralData];
    [self startAudioAndAnimation];
	
	AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	client = [appDelegate client];

}


/***********************************************************************/
// touch functions
//  convenience functions



float fZeroIfOverCeiling(float val, float ceiling) {
	float absVal = fabs(val);
	if (absVal > ceiling) return 0;
	else return val;
}
float fCapToBounds(float val, float min, float max) {
	float output = val;
	output = (output < min)? min : output;
	output = (output > max)? max : output;
	return output;
}


// computes distance between two touches 
- (CGFloat)distanceFromPoint:(CGPoint)point0 toPoint:(CGPoint)point1 {
	float x = point1.x - point0.x;
	float y = point1.y - point0.y;
	return sqrt(x*x + y*y);
}


// computes current touch location/distance
-(void)setInitialTouchValues:(NSSet*)touches {
	// switch on number of touches
	// set prevTouchPoint and prevTouchDistance accordingly
	switch ([touches count]) {
		case 1: {
			UITouch* touch = [touches anyObject];
			prevTouchPoint = [touch locationInView:touch.view];
			prevTouchDistance = 0;
			break;
		}
		case 2: {
			UITouch *touch0 = [[touches allObjects] objectAtIndex:0];
			UITouch *touch1 = [[touches allObjects] objectAtIndex:1];
			CGPoint point0 = [touch0 locationInView:touch0.view];
			CGPoint point1 = [touch1 locationInView:touch1.view];
			prevTouchDistance = [self distanceFromPoint:point0 toPoint:point1];
			prevTouchPoint = point0;
			break;
		}
		default:
			break;
	}
}


// called when touches begin: calls setInitialTouchValues, resets overlay
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setInitialTouchValues:[event allTouches]];
	[overlayViewController resetVisible];
}


// called when touches move: adjusts camera based on movement
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"Touches moved. Count = %d",[[event allTouches] count]);
	// switch on number of touches
	NSSet* allTouches = [event allTouches];
	switch ([allTouches count]) {
		
		// one touch: adjust camera yz-theta (angle of eye above z-axis) and/or x-offset
		case 1: {
			
			// get the touch and find its location
			UITouch *touch = [allTouches anyObject];
			CGPoint currentTouchPoint = [touch locationInView:touch.view];
			
			// compute change from previous
//			float deltaX = currentTouchPoint.x - prevTouchPoint.x;
//			float deltaY = currentTouchPoint.y - prevTouchPoint.y;
			float deltaX = currentTouchPoint.y - prevTouchPoint.y;
			float deltaY = currentTouchPoint.x - prevTouchPoint.x;

			
			// prevent nasty jumps by putting a ceiling on touch distance
			static const float deltaTouchCeiling = 60;
			deltaX = fZeroIfOverCeiling(deltaX, deltaTouchCeiling);
			deltaY = fZeroIfOverCeiling(deltaY, deltaTouchCeiling);
			
			// scale values
			deltaX *= scaleOneTouchX;
			deltaY *= scaleOneTouchY;
			
			/*
			// adjust camera yz-theta based on touch y, cap to allowable range
			cameraYZTheta = cameraYZTheta + deltaY;
			static const float minCameraYZTheta = 0.;
			static const float maxCameraYZTheta = M_PI/2.1;
			if (cameraYZTheta < minCameraYZTheta) cameraYZTheta = minCameraYZTheta;
			if (cameraYZTheta > maxCameraYZTheta) cameraYZTheta = maxCameraYZTheta;
			 */
			float newY = camera.eye.y - deltaY;
			static const float maxCameraY = 8.0f;
			camera.eye.y = fCapToBounds(newY, 0.0f, maxCameraY);
			
			// adjust camera x based on touch x, cap to allowable range
			cameraXOffset += deltaX;
			float maxCameraXOffset = (float)(pianoModel.width/2.);
			float minCameraXOffset = -1*maxCameraXOffset;
			cameraXOffset = fCapToBounds(cameraXOffset, minCameraXOffset, maxCameraXOffset);
			
			
			/*
			minDisplayFreq += deltaX;
			maxDisplayFreq += deltaX;
			if (minDisplayFreq < minDisplayFreqBound) minDisplayFreq = minDisplayFreqBound;
			if (maxDisplayFreq > maxDisplayFreqBound) maxDisplayFreq = maxDisplayFreqBound;
			cameraXOffset = cameraXOffset - deltaY;
			static const float minCameraX = -8.;
			static const float maxCameraX = 8.;
			if (cameraXOffset < minCameraX) cameraXOffset = minCameraX;
			if (cameraXOffset > maxCameraX) cameraXOffset = maxCameraX;
			[overlayViewController setMinFreq:minDisplayFreq maxFreq:maxDisplayFreq logBase:1.0f];
			 */
			
			/*
			minAudioDataIndex += (int)roundf(deltaX);
			minAudioDataIndex = (minAudioDataIndex > 0)? minAudioDataIndex : 0;
			int maxIndexCap = audioManager.spectrumLen - audioModelXDataLen;
			minAudioDataIndex = (minAudioDataIndex < maxIndexCap)? minAudioDataIndex : maxIndexCap;
			[overlayViewController setMinFreqLbl:minAudioDataIndex maxFreqLbl:0];
			 */
			
			/*
			int deltaXInt = (int)deltaX;
			loFreqIndex += deltaXInt;
			hiFreqIndex += deltaXInt;
			[overlayViewController setMinFreqLbl:loFreqIndex maxFreqLbl:hiFreqIndex];
			 */
	
			// new camera location based on yz-theta
			//camera.eye.y = cameraYZRadius*sinf(cameraYZTheta) + cameraYOffset;
			//camera.eye.z = cameraYZRadius*cosf(cameraYZTheta) + cameraZOffset;
			
			
			// update prevTouchPoint
			prevTouchPoint = currentTouchPoint;
			
			break;
		}
		
		// DOLHANSKY: Pinch gesture
		// two touches: adjust model width
//		case 2: {
//			
//			// get the touches and compute the distance
//			UITouch *touch0 = [[allTouches allObjects] objectAtIndex:0];
//			UITouch *touch1 = [[allTouches allObjects] objectAtIndex:1];
//			CGPoint point0 = [touch0 locationInView:touch0.view];
//			CGPoint point1 = [touch1 locationInView:touch1.view];
//			float currentTouchDist = [self distanceFromPoint:point0 toPoint:point1];
//			
//			// compute change from previous
//			float deltaDist = currentTouchDist - prevTouchDistance;
//			
//			// prevent nasty jumps by putting a ceiling on touch distance
//			static const float deltaDistCeiling = 40;
//			float absDeltaDist = fabs(deltaDist);
//			deltaDist = absDeltaDist > deltaDistCeiling ? 0 : deltaDist;
//			
//			// scale value
//			deltaDist *= scaleTwoTouchDist;
//			deltaDist = powf(2.0f, deltaDist);
//			
//			/*
//			// adjust radius, cap to allowable range
//			cameraYZRadius = cameraYZRadius - deltaDist;
//			static const float minCameraYZRadius = 1.;
//			static const float maxCameraYZRadius = 768.;
//			if (cameraYZRadius < minCameraYZRadius) cameraYZRadius = minCameraYZRadius;
//			if (cameraYZRadius > maxCameraYZRadius) cameraYZRadius = maxCameraYZRadius;
//			 */
//			
//			// adjust size of model
//			float newWidth = fCapToBounds((float)pianoModel.width*deltaDist, 2.0, 20.0);
//			AudioModelSetDimensions(&pianoModel, pianoModel.length, (GLfloat)newWidth, pianoModel.height);
//			
//			// adjust offset to keep the model from moving left to right
//			cameraXOffset *= deltaDist;
//			
//			/*
//			// set new location of camera eye
//			camera.eye.y = cameraYZRadius*sinf(cameraYZTheta)+cameraYOffset;
//			camera.eye.z = cameraYZRadius*cosf(cameraYZTheta)+cameraZOffset;
//			 */
//			 
//			// update prevTouchDistance
//			prevTouchDistance = currentTouchDist;
//			
//			break;
//		}
		default:
			break;
	}
	
	// set camera from x offset
	camera.eye.x = cameraXOffset;
	camera.center.x = cameraXOffset;
	
}


// called when touches end: 
//	resets initial touch values in case we're moving from 2 touches to 1
//	starts overlay fading
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *allTouches = [event allTouches];
	if ([allTouches count] == 2) {
		// maybe we don't need this?
		//[self setInitialTouchValues:allTouches];
	}
	
#if DEBUG_TOUCH_LOCATIONS
	NSLog(@"eye     (%.1f, %.1f, %.1f)",camera.eye.x, camera.eye.y, camera.eye.z);
	NSLog(@"center  (%.1f, %.1f, %.1f)",camera.center.x, camera.center.y, camera.center.z);
	NSLog(@"up      (%.1f, %.1f, %.1f)",camera.up.x, camera.up.y, camera.up.z);
#endif
	
	[overlayViewController startFade];
	
}

/***********************************************************************/
// other functions


- (void)dealloc {
	//MATT Comment [audioManager release];
	//MATT Comment [overlayViewController release];
	AudioModelDestroy(&pianoModel);
	AudioModelDestroy(&trumpetModel);
	AudioModelDestroy(&bassModel);
	AudioModelDestroy(&drumsModel);
	
	free(pianoModelBuffer);
	free(trumpetModelBuffer);
	free(bassModelBuffer);
	free(drumsModelBuffer);
    
    //MATT Comment [drumsData release];
    //MATT Comment [bassData release];
    //MATT Comment [pianoData release];
    //MATT Comment [trumpetData release];
	//MATT Comment [client release];
    
    //MATT Comment  [super dealloc];
}

-(void) stopSpectrum {
    specRunning = NO;
}

-(void) startSpectrum {
    specRunning = YES;
}



@end
