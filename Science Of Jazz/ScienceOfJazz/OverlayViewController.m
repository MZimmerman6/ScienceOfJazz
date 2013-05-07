//
//  OverlayViewController.m
//  Spectrum3D
//
//  Created by default on 6/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"


@implementation OverlayViewController

-(void) renderFrame {
	if (isFading) {
		if (self.view.alpha > minOverlayAlpha) {
			if (numFramesAtMaxAlpha < numFramesToStayMaxAlpha) {
				numFramesAtMaxAlpha++;
			} else {
				if (numFramesBeenFading < numFramesToFade) {
					numFramesBeenFading++;
					self.view.alpha = self.view.alpha - fadeAlphaPerFrame;
				}
			}
		} else {
			isFading = NO;
		}
	}
}

-(void)resetVisible {
	self.view.alpha = maxOverlayAlpha;
	isFading = NO;
}

-(void)startFade {
	numFramesAtMaxAlpha = 0;
	numFramesBeenFading = 0;
	isFading = YES;
}

-(void)setMinFreqLbl:(float)minFreq maxFreqLbl:(float)maxFreq {
	[minFreqLbl setText:[NSString stringWithFormat:@"%.0f Hz",roundf(minFreq)]];
	[maxFreqLbl setText:[NSString stringWithFormat:@"%.0f Hz",roundf(maxFreq)]];
}

-(id)initWithFramerate:(float)framerate {
	if (self = [super init]) {
		numFramesToStayMaxAlpha = (int)roundf(numSecsMaxAlpha*framerate);
		numFramesToFade = (int)roundf(numSecsToFade*framerate);
		numFramesAtMaxAlpha = 0;
		numFramesBeenFading = 0;
		fadeAlphaPerFrame = (maxOverlayAlpha - minOverlayAlpha)/numFramesToFade;
		self.view.alpha = minOverlayAlpha;
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	[self.view setCenter:CGPointMake(150, 240)];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
