//
//  SpectrumViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLViewController.h"
#import "SpectrumInfoViewController.h"

@class GLViewController;
@class GLView;

@interface SpectrumViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    UIWindow *window;
    GLView *glView;
    GLViewController *glViewController;
    int numTouches;
    int counter;
    NSTimer *tapTimer;
    BOOL timerRunning;
    BOOL barAdded;
    UIToolbar *bottomBar;
    BOOL firstView;
    
    NSMutableData *picData;
    UIImageView *labelView;
    UIButton *infoButton;
    
    SpectrumInfoViewController *spectrumInfo;
    NSArray *instruments;
    
    UILabel *inst1Label;
    UILabel *inst2Label;
    UILabel *inst3Label;
    UILabel *inst4Label;
    
    BOOL spectrumRunning;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GLView *glView;
@property (strong, nonatomic) GLViewController *glViewController;


//-(void) timerAction;

-(void) doneFadingToolbar;

-(void) backPressed;

//-(void) startTimer;

-(void) infoPressed;

-(void) updateSpectrumParameters:(NSDictionary*)parameters;

@end
