//
//  SoundFieldViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundFieldViewController.h"


@interface SoundFieldViewController ()

@end

#define UPDATE_TIME .5
#define ARC4RANDOM_MAX      0x100000000
#define BLOB_SIZE 30


@implementation SoundFieldViewController

@synthesize overlayView, powerScaling, overlayShift;

#pragma mark - Custom methods
- (void)updateWithX:(int)blobX y:(int)blobY intensity:(CGFloat)intensity {
    NSNumber* x = [NSNumber numberWithInt:blobX];
    NSNumber* y = [NSNumber numberWithInt:blobY];
    NSMutableDictionary* yDict = [blobXDictionary objectForKey:x];
    if (yDict != nil) {
        SoundBlob* updateBlob = [yDict objectForKey:y];
        
        if (updateBlob != nil && updateBlob != (SoundBlob*)user) {
            [updateBlob changeIntensity:intensity];
        } else{
            NSLog(@"not updating user blob");
        }
    }
}

- (void)addBlob:(int)newX y:(int)newY {
    NSNumber* x = [NSNumber numberWithInt:newX];
    NSNumber* y = [NSNumber numberWithInt:newY];
    SoundBlob* newBlob;
    
    NSMutableDictionary* yDict = [blobXDictionary objectForKey:x];
    if (yDict == nil) { // No points stored for this x value
        NSMutableDictionary* blobYDictionary = [NSMutableDictionary new];
        newBlob = [[SoundBlob alloc] initWithX:[x intValue] y:[y intValue]];
        [blobYDictionary setObject:newBlob forKey:y];
        [blobXDictionary setObject:blobYDictionary forKey:x];
        [blobList addObject:newBlob];
        
    } else { // There are points stored for this x, but the passed point still might not exist
        SoundBlob* testBlob = [yDict objectForKey:y];
        if (testBlob == nil) { // The passed point does not exist
            newBlob = [[SoundBlob alloc] initWithX:[x intValue] y:[y intValue]];
            [yDict setObject:newBlob forKey:y];
            [blobList addObject:newBlob];
        } else {
//            NSLog(@"ALREADY EXISTS");
        }
    }
    
    if (newBlob != nil) {
        [overlayView addSubview:[newBlob view]];
    }
}

-(UserBlobs*) addUserBlob:(int)newX y:(int)newY {
    NSNumber* x = [NSNumber numberWithInt:newX];
    NSNumber* y = [NSNumber numberWithInt:newY];
    UserBlobs* newBlob;
    
    NSMutableDictionary* yDict = [blobXDictionary objectForKey:x];
    if (yDict == nil) { // No points stored for this x value
        NSMutableDictionary* blobYDictionary = [NSMutableDictionary new];
        newBlob = [[UserBlobs alloc] initWithX:[x intValue] y:[y intValue]];
        //[blobList addObject:newBlob];
        [blobYDictionary setObject:newBlob forKey:y];
        [blobXDictionary setObject:blobYDictionary forKey:x];
        
    } else { // There are points stored for this x, but the passed point still might not exist
        SoundBlob* testBlob = [yDict objectForKey:y];
        if (testBlob == nil) { // The passed point does not exist
            newBlob = [[UserBlobs alloc] initWithX:[x intValue] y:[y intValue]];
            //[blobList addObject:newBlob];
            [yDict setObject:newBlob forKey:y];
        } else {
//            NSLog(@"ALREADY EXISTS");
        }
    }
    
    if (newBlob != nil) {
        [overlayView addSubview:[newBlob view]];
    }
    
    return newBlob;
}

-(void) removeUserBlob:(int)oldX y:(int)oldY {
    
    NSNumber *x = [NSNumber numberWithInt:oldX];
    NSNumber *y = [NSNumber numberWithInt:oldY];
    NSMutableDictionary *yDictionary = [blobXDictionary objectForKey:x];
    if (yDictionary != nil) {
        if ([yDictionary objectForKey:y]) {
            [yDictionary removeObjectForKey:y];
            NSLog(@"removed from y dict");
            if ([yDictionary count] ==0) {
                [blobXDictionary removeObjectForKey:x];
                NSLog(@"removed from xdict");
            }
        }
    }
}


- (void)pointsUpdate {
    
//    NSLog(@"%d",[blobList count]);
    
     for (int i=0; i<[blobList count]; i++) {
        SoundBlob* blob = [blobList objectAtIndex:i];
        [self updateWithX:[blob getX] y:[blob getY] intensity:[blob getIntensity]-0.02];
     }
    
    NSMutableArray* updates = [client getCurrentLocations];
    
    float* bytes = (float*)malloc(sizeof(float)*16);
    
    for(int i = 0; i<16;i++)
    {
        bytes[i] = 0;
    }
    if([updates count]>0)
    {
        for(NSData* jawn in updates)
        {
            [jawn getBytes:bytes];
            [self addBlob:(int)bytes[4] y:(int)bytes[5]];
            [self updateWithX:(int)bytes[4] y:(int)bytes[5] intensity:bytes[6]];
        }
        
    }
    free(bytes);
    
    // for (int i=0; i<[blobList count]; i++) {
    //     double doUpdate = ((double)arc4random() / ARC4RANDOM_MAX);
    //     if (doUpdate < 0.1) {
    //         double intensity = ((double)arc4random() / ARC4RANDOM_MAX);
    //         //            [[blobList objectAtIndex:i] changeIntensity:intensity];
    //        SoundBlob* blob = [blobList objectAtIndex:i];
    //        [self updateWithX:[blob getX] y:[blob getY] intensity:intensity];
    //    }
    //}
    [updates removeAllObjects];
}


-(void) soundFieldAppSleeping {
//    NSLog(@"called when app went to sleep in sound field ");
    appSleeping = YES;
    [powerTimer invalidate];
    [recorder pause];
}

-(void) soundFieldAppUnSleep {
//    [self startMeasurement];
    appSleeping = NO;
}


#pragma mark - Debug methods, replace with network code

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    locationChosen = false;
    gotIP = NO;
    measurementsStarted = NO;
    [super viewDidLoad];
    
//    overlayShift = 50;
//    powerScaling = 512;
//    
//    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, overlayShift, 320, 416)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:overlayView];
    
    soundfieldInfo = [[SoundFieldInfoViewController alloc] initWithNibName:@"SoundFieldInfoViewController" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate setSoundField:self];
	client = [appDelegate client];
    server = [appDelegate server];
    
    powerValue = 0;
    blobXDictionary = [[NSMutableDictionary alloc] init];
    
    // DEBUG: Remove the following
    blobList = [NSMutableArray new];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(pointsUpdate) userInfo:nil repeats:YES];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton setAlpha:0.8];
    if (screenBounds.size.height == 568) {
        [infoButton setFrame:CGRectMake(285, 470, 25, 25)];
    } else {
        [infoButton setFrame:CGRectMake(285, 385, 25, 25)];
    }
    [infoButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:infoButton];
    
//    [self.view addSubview:bottomBar];
//    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
//                                   initWithTitle:@"Back"                                            
//                                   style:UIBarButtonItemStyleBordered 
//                                   target:self 
//                                   action:@selector(backPressed)];
//    
//    UIBarButtonItem *locateButton = [[UIBarButtonItem alloc] 
//                                   initWithTitle:@"Locate"                                            
//                                   style:UIBarButtonItemStyleBordered 
//                                   target:self 
//                                   action:@selector(enableLocationChoosing)];
//    
//    UIBarButtonItem	*flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    
//    NSArray *buttonArray = [[NSArray alloc] initWithObjects:backButton,flex,locateButton, nil];
//    [bottomBar setItems:buttonArray];
    
//    [self setupAudioRecording];
    
//    userImage = [[UIImageView alloc] initWithFrame:CGRectMake(30,30,50, 50)];
//    userImage.image = [UIImage imageNamed:@"UserBlob.png"];
//    [self.view addSubview:userImage];
}

-(void) infoPressed {
    [self.navigationController pushViewController:soundfieldInfo animated:YES];
}

-(void) enableLocationChoosing {
    choseLocationEnabled = YES;
}

-(void) viewDidAppear:(BOOL)animated {
//    NSLog(@"view appeared");
    if (!measurementsStarted) {
        [self startMeasurement];
    }
}

-(void) setupAudioRecording {
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setObject:[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey: AVFormatIDKey];
    [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
    //    [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    NSURL *recURL = [[NSURL alloc] initFileURLWithPath:@"/dev/null"];
    recorder = [[AVAudioRecorder alloc] initWithURL: recURL
                                           settings: recordSettings
                                              error: nil];
    
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = TRUE;
    
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (choseLocationEnabled) {
//        NSLog(@"getting user location by touch");
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touch ended");
    UITouch *touchTemp = [touches anyObject];
    userLocation = [touchTemp locationInView:overlayView];
//    NSLog(@"%f,%f",userLocation.x,userLocation.y);
    if (choseLocationEnabled) {
        float* data = (float*)malloc(sizeof(float)*16);
        
        data[0] = 4;
        data[1] = 3;
        data[2] = 2;
        data[3] = 1;
        float x = [user getX];
        float y = [user getY];
        
        data[4] = x;
        data[5] = y;
        
        data[6] = 0;
        
        for(int i = 7; i<16;i++)
        {
            data[i] = 0;
        }
        
        [server sendMulticast:data withLength:sizeof(float)*16];
        
        free(data);
        
        UITouch *touch = [touches anyObject];
        userLocation = [touch locationInView:overlayView];
        if (userLocation.x < 0) {
            userLocation.x = 0;
        } else if (userLocation.x > 320) {
            userLocation.x = 320;
        }
        
        if (userLocation.y < 0) {
            userLocation.y = 0;
        } else if (userLocation.y > 416) {
            userLocation.y = 416;
        }
        if (!user) {
            user = [self addUserBlob:userLocation.x-BLOB_SIZE/2 y:userLocation.y-BLOB_SIZE/2];
            [blobList addObject:user];
        } else {
            [self removeUserBlob:[user getX] y:[user getY]];
            [user.view removeFromSuperview];
            user = [self addUserBlob:userLocation.x-BLOB_SIZE/2 y:userLocation.y-BLOB_SIZE];
            [blobList addObject:user];
        }
        NSLog(@"%f,%f",userLocation.x,userLocation.y);
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setLocation:userLocation];
//        [userImage setFrame:CGRectMake(userLocation.x, userLocation.y, 30, 30)];
        locationChosen = true;
    }
    choseLocationEnabled = NO;
}

-(void) updateUserBlob:(CGPoint)location {
    
    userLocation = location;
    if (!user) {
        user = [self addUserBlob:userLocation.x-BLOB_SIZE/2 y:userLocation.y-BLOB_SIZE/2];
        [blobList addObject:user];
    } else {
        [self removeUserBlob:[user getX] y:[user getY]];
        [user.view removeFromSuperview];
        user = [self addUserBlob:userLocation.x-BLOB_SIZE/2 y:userLocation.y-BLOB_SIZE];
        [blobList addObject:user];
    }
    NSLog(@"%f,%f",userLocation.x,userLocation.y);
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)locatePressed:(id)sender {
    [self enableLocationChoosing];
}

-(BOOL) startMeasurement {
//    if (!gotIP) {
        ipAddress = [self getIPAddress];
//        gotIP = YES;
//    }
    [recorder record];
    powerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doPowerStuff) userInfo:nil repeats:YES];
    measurementsStarted = YES;
    return YES;
}

-(void) doPowerStuff {
//    [recorder updateMeters];
//    powerValue = [recorder averagePowerForChannel:0];
//    NSLog(@"Average power for channel %i:%4.2f",0,powerValue);
//    NSLog(@"sent power");
//    NSLog(@"%i",powerScaling);
    powerValue /= (float)powerScaling;
//    NSLog(@"%f",powerValue);
    if (!appSleeping) {
            [self sendPowerValue];
            [self updateUserIntensity];
//            NSLog(@"sent power - Power = %f",powerValue);
    }
}

-(void) sendPowerValue {
    if(locationChosen)
    {
        float* data = (float*)malloc(sizeof(float)*16);
        
        data[0] = 4;
        data[1] = 3;
        data[2] = 2;
        data[3] = 1;
        float x = [user getX];
        float y = [user getY];
        
        data[4] = x;
        data[5] = y;
        
        data[6] = (powerValue+[client getSoundFieldAdd])* [client getSoundFieldMult];
        if (data[6]>1) {
            data[6]=1;
        }
        
        for(int i = 7; i<16;i++)
        {
            data[i] = 0;
        }
        
        [server sendMulticast:data withLength:sizeof(float)*16];
        
        free(data);
    }
}

-(void) setAudioPower:(float)power {
    powerValue = power;
}


-(void) updateUserIntensity {
//    NSLog(@"Power = %f",powerValue);
//    NSLog(@"Offset = %f",[client getSoundFieldAdd]);
//    NSLog(@"Gain = %f",[client getSoundFieldMult]);
    float intensity;
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate checkLocationHighlight]==1) {
        intensity = 1;
    } else {
        intensity = powerValue*[client getSoundFieldMult]+[client getSoundFieldAdd];
    }
//    NSLog(@"Intensity = %f",intensity);
    if (intensity >1){
        intensity = 1;
    }
    
    [user changeIntensity:intensity];
//    NSLog(@"Intensity for UserBlob: %f",intensity);

}

-(BOOL) stopEchoLocation {
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

-(void) updateBackgroundImage:(UIImage *)image {
    backgroundImage.image = image;
    [backgroundImage setNeedsDisplay];
}

-(void) updateSoundFieldOverlayShift:(int)shift andScaling:(int)scaling {
    
    [self setOverlayShift:shift];
    [self setPowerScaling:scaling];
    [self performSelectorOnMainThread:@selector(shiftOverlay) withObject:nil waitUntilDone:NO];
    powerScaling = scaling;
    [overlayView setNeedsDisplay];
    [self.view setNeedsDisplay];
}

-(void) shiftOverlay {
    
    [overlayView removeFromSuperview];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (bounds.size.height == 568) {
        overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, overlayShift, 320, 416)];
    } else {
        overlayView.frame = CGRectMake(0, 0, 320, 416);
    }
    [overlayView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:overlayView];
}

@end
