//
//  SOMViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METFrameworks.h"
#import "ChromaWheelViewController.h"
#import "SpectrumViewController.h"
#import "SoundFieldViewController.h"
#import "SOMInformationViewController.h"
#import "TakeOverViewController.h"

@class SpectrumViewController;
@class SoundFieldViewController;
@class ChromaWheelViewController;

@interface SOMViewController : UIViewController  {
    
    
    NSMutableArray *SOMIcons;
    
    ChromaWheelViewController *chromaViewController;
    SpectrumViewController *spectrumViewController;
    SoundFieldViewController *soundFieldViewController;
    SOMInformationViewController *somInfoViewController;
    TakeOverViewController *takeOverViewController;
    NSTimer *infoTimer;
    BOOL firstOpen;
    
    NSTimer *updateTimer;
    
}

-(IBAction)chromaPressed:(id)sender;

-(IBAction)spectrumPressed:(id)sender;

-(IBAction)soundfieldPressed:(id)sender;

-(IBAction)infoPressed:(id)sender;

-(void) updateChromaViewController:(NSDictionary*)parameters;

-(void) updateSpectrumViewController:(NSDictionary*)parameters;

-(void) updateSoundFieldPower:(float)power;

-(void) updateSoundFieldBackground:(UIImage*)image;

-(void) updateSoundFieldOverlayShift:(int)shift andScaling:(int)scaling;

-(void) pushTakeOverController;

-(void) removeTakeOverController;

-(void) updateTakeoverScreenWithColor:(UIColor*)color;

-(void) updateSoundFieldUserLocation:(CGPoint)point;

@end
