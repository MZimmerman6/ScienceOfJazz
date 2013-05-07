//
//  OverlayViewController.h
//  Spectrum3D
//
//  Created by default on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


static const float maxOverlayAlpha = 0.8;
static const float minOverlayAlpha = 0.0;
static const float numSecsMaxAlpha = 1.3;
static const float numSecsToFade = 1.8;


@interface OverlayViewController : UIViewController {

	int numFramesToStayMaxAlpha;
	int numFramesToFade;
	int numFramesAtMaxAlpha;
	int numFramesBeenFading;
	float fadeAlphaPerFrame;
	
	BOOL isFading;
	
	IBOutlet UILabel* minFreqLbl;
	IBOutlet UILabel* maxFreqLbl;
}

-(void)renderFrame;
-(void)resetVisible;
-(void)startFade;
-(id)initWithFramerate:(float)framerate;
-(void)setMinFreqLbl:(float)minFreq maxFreqLbl:(float)maxFreq;

@end
