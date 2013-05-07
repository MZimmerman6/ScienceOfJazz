//
//  ChromaWheelViewController.h
//  ScienceOfMusic
//
//  Created by Matthew Zimmerman on 3/26/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MulticastClient.h"
#import "AppDelegate.h"
#import "ChromaInfoViewController.h"
@interface ChromaWheelViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    NSMutableArray* largeSegmentViews;
    NSMutableArray* medSegmentViews;
    NSMutableArray* smallSegmentViews;
    
    NSMutableArray* bassChromaData;
    NSMutableArray* trumpetChromaData;
    NSMutableArray* pianoChromaData;
    
    AVAudioPlayer* audioPlayer;
    NSTimer *animationTimer;
    int chromaCounter;
    MulticastClient* client;
    
    
    UIImageView *labelView;
    NSMutableData *picData;
    
    ChromaInfoViewController *chromaInfo;
    NSDictionary *chromaParameters;
    BOOL fifthsActive;
    NSMutableArray *instruments;
    BOOL chromaRunning;
    
    NSMutableArray *textLabels;
    
}

-(void) backPressed;

-(void) infoPressed;

-(void) updateChromaWheel:(NSDictionary*)parameters;

-(void) addLabels;

-(void) removeAllSubviews;
@end
