//
//  ChromaWheelViewController.m
//  ScienceOfMusic
//
//  Created by Matthew Zimmerman on 3/26/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "ChromaWheelViewController.h"

@interface ChromaWheelViewController ()

@end

@implementation ChromaWheelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        instruments = [[NSMutableArray alloc] init];
        [instruments addObject:@"Sax"];
        [instruments addObject:@"Keys"];
        [instruments addObject:@"Drums"];
        
        chromaRunning = YES;
        fifthsActive = YES;
        textLabels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setupWheels {
    
    largeSegmentViews = [NSMutableArray new];
    medSegmentViews = [NSMutableArray new];
    smallSegmentViews = [NSMutableArray new];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    double xMid;
    double yMid;
    double layerDepth = 62;
    double circleRadius = 250;
    
    if (screenBounds.size.height == 568) {
        xMid = 160;
        yMid = 262;
    } else {
        xMid = 160;
        yMid = 212;
    }
    
    for (int i=0; i<12; i++) {
        UIImageView* imageViewLarge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LargeSegment.png"]];
        UIImageView* imageViewMed = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MedSegment.png"]];
        UIImageView* imageViewSmall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmallSegment.png"]];
        imageViewLarge.layer.anchorPoint = CGPointMake(0, 0/480.0); // Set the anchor point to the top-left part of the image
        imageViewMed.layer.anchorPoint = CGPointMake(0, 0/480.0); 
        imageViewSmall.layer.anchorPoint = CGPointMake(0, 0/480.0);
        double scale = 0.6;
        double ang = (double)i/12.0*2.0*M_PI-((360.0/12.0)/2*M_PI/180.0);
        double rotationFudge = 0.015; // For some reason the segments don't rotate correctly
        
        // Scale and translate
        double r = circleRadius;
        imageViewLarge.frame = CGRectMake(xMid+scale*r*cos(ang), yMid+scale*r*sin(ang), scale*130, scale*92);
        // Rotate
        imageViewLarge.transform = CGAffineTransformMakeRotation(ang+M_PI/2.0+rotationFudge);
        
        // Scale and translate
        r = circleRadius-layerDepth;
        imageViewMed.frame = CGRectMake(xMid+scale*r*cos(ang), yMid+scale*r*sin(ang), scale*98, scale*83);
        // Rotate
        imageViewMed.transform = CGAffineTransformMakeRotation(ang+M_PI/2.0+rotationFudge);
        
        // Scale and translate
        r = circleRadius-2*layerDepth;
        imageViewSmall.frame = CGRectMake(xMid+scale*r*cos(ang-rotationFudge), yMid+scale*r*sin(ang-rotationFudge), scale*67, scale*76);
        // Rotate
        imageViewSmall.transform = CGAffineTransformMakeRotation(ang+M_PI/2.0+rotationFudge);
        
        [imageViewLarge setAlpha:0.5];
        [imageViewMed setAlpha:0.5];
        [imageViewSmall setAlpha:0.5];
        
        [[self view] addSubview:imageViewLarge];
        [[self view] addSubview:imageViewMed];
        [[self view] addSubview:imageViewSmall];
        
        r = 220;
        int offsetX = -10;
        int offsetY = -10;
        ang = -ang-(360.0/12.0)/2.0*M_PI/180.0;
        
        if (!fifthsActive) {
            ang = - ang;
        }
        CGRect frameRectText = CGRectMake(xMid+scale*r*cos(ang)+offsetX, yMid+scale*r*sin(ang)+offsetY, scale*130, scale*92);
        UITextField *myTextField = [[UITextField alloc] initWithFrame:frameRectText];
//        [self.view addSubview:myTextField];
        NSString *str;
        if (fifthsActive) {
            switch (i) {
                case 0:
                    str = @"A";
                    break;
                case 1:
                    str = @"D";
                    break;
                case 2:
                    str = @"G";
                    break;
                case 3:
                    str = @"C";
                    break;
                case 4:
                    str = @"F";
                    break;
                case 5:
                    str = @"A#";
                    break;
                case 6:
                    str = @"D#";
                    break;
                case 7:
                    str = @"G#";
                    break;
                case 8:
                    str = @"C#";
                    break;
                case 9:
                    str = @"F#";
                    break;
                case 10:
                    str = @"B";
                    break;
                case 11:
                    str = @"E";
                    break;
                default:
                    break;
            }
        } else {
            switch (i) {
                case 0:
                    str = @"A";
                    break;
                case 1:
                    str = @"A#";
                    break;
                case 2:
                    str = @"B";
                    break;
                case 3:
                    str = @"C";
                    break;
                case 4:
                    str = @"C#";
                    break;
                case 5:
                    str = @"D";
                    break;
                case 6:
                    str = @"D#";
                    break;
                case 7:
                    str = @"E";
                    break;
                case 8:
                    str = @"F";
                    break;
                case 9:
                    str = @"F#";
                    break;
                case 10:
                    str = @"G";
                    break;
                case 11:
                    str = @"E";
                    break;
                default:
                    break;
            }
        }
        
        [myTextField setText:str];
        [myTextField setTextColor:[UIColor whiteColor]];
        
        [largeSegmentViews addObject:imageViewLarge];
        [medSegmentViews addObject:imageViewMed];
        [smallSegmentViews addObject:imageViewSmall];
        [textLabels addObject:myTextField];
    }
    
    
    for (UITextField *field in textLabels) {
        [self.view addSubview:field];
    }
    NSLog(@"Wheels added.\n");
    
}

- (void)loadAudio {
    NSURL* url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/jazz.mp3", [[NSBundle mainBundle] resourcePath]]];
    
    NSError* error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 1;
    
    if (audioPlayer == nil) {
        NSLog(@"%@", [error description]);
    } else {
        NSLog(@"Audio loaded.\n");
        audioPlayer.volume = 1.0;
//        [audioPlayer play];
    }
}

- (void)loadChromaData {
    bassChromaData = [NSMutableArray new];
    trumpetChromaData = [NSMutableArray new];
    pianoChromaData = [NSMutableArray new];
    
    NSString* bassPath = [[NSBundle mainBundle] pathForResource:@"bass" ofType:@"txt"];
    NSString* trumpetPath = [[NSBundle mainBundle] pathForResource:@"trumpet" ofType:@"txt"];
    NSString* pianoPath = [[NSBundle mainBundle] pathForResource:@"piano" ofType:@"txt"];
    
    NSStringEncoding encoding;
    NSError* error;
    NSString* bassData = [NSString stringWithContentsOfFile:bassPath usedEncoding:&encoding error:&error];
    NSString* trumpetData = [NSString stringWithContentsOfFile:trumpetPath usedEncoding:&encoding error:&error];
    NSString* pianoData = [NSString stringWithContentsOfFile:pianoPath usedEncoding:&encoding error:&error];
    
    double bassMax = 1.0;
    double pianoMax = 1.0;
    double trumpetMax = 1.0;
    
    NSArray* bassLines = [bassData componentsSeparatedByString:@"\n"];
    for (int i=0; i<[bassLines count]; i++) {
        NSArray* chroma = [[bassLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* fullChroma = [[NSMutableArray alloc] init];
        for (int j=0; j<[chroma count]; j++) {
            NSString* c = [chroma objectAtIndex:j];
            if ([c doubleValue] > bassMax) {
                bassMax = [c doubleValue];
            }
            [fullChroma addObject:[NSNumber numberWithDouble:[c doubleValue]]];
        }
        
        [bassChromaData addObject:fullChroma];
    }
    
    NSArray* trumpetLines = [trumpetData componentsSeparatedByString:@"\n"];
    for (int i=0; i<[trumpetLines count]; i++) {
        NSArray* chroma = [[trumpetLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* fullChroma = [[NSMutableArray alloc] init];
        for (int j=0; j<[chroma count]; j++) {
            NSString* c = [chroma objectAtIndex:j];
            if ([c doubleValue] > trumpetMax) {
                trumpetMax = [c doubleValue];
            }
            [fullChroma addObject:[NSNumber numberWithDouble:[c doubleValue]]];
        }
        
        [trumpetChromaData addObject:fullChroma];
    }
    
    NSArray* pianoLines = [pianoData componentsSeparatedByString:@"\n"];
    for (int i=0; i<[trumpetLines count]; i++) {
        NSArray* chroma = [[pianoLines objectAtIndex:i] componentsSeparatedByString:@","];
        NSMutableArray* fullChroma = [[NSMutableArray alloc] init];
        for (int j=0; j<[chroma count]; j++) {
            NSString* c = [chroma objectAtIndex:j];
            if ([c doubleValue] > pianoMax) {
                pianoMax = [c doubleValue];
            }
            [fullChroma addObject:[NSNumber numberWithDouble:[c doubleValue]]];
        }
        [pianoChromaData addObject:fullChroma];
    }
    
    double bassThreshold = 0.7;
    double trumpetThreshold = 0.3;
    double pianoThreshold = 0.3;
    
    
    // Scale chroma data
    for (int i=0; i<[bassChromaData count]; i++) {
        NSMutableArray* fullChroma = [bassChromaData objectAtIndex:i];
        for (int j=0; j<[fullChroma count]; j++) {
            double val = [[fullChroma objectAtIndex:j] doubleValue]/(bassMax * bassThreshold);
            [fullChroma replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
    
    for (int i=0; i<[trumpetChromaData count]; i++) {
        NSMutableArray* fullChroma = [trumpetChromaData objectAtIndex:i];
        for (int j=0; j<[fullChroma count]; j++) {
            double val = [[fullChroma objectAtIndex:j] doubleValue]/(trumpetMax * trumpetThreshold);
            [fullChroma replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
    
    for (int i=0; i<[pianoChromaData count]; i++) {
        NSMutableArray* fullChroma = [pianoChromaData objectAtIndex:i];
        for (int j=0; j<[fullChroma count]; j++) {
            double val = [[fullChroma objectAtIndex:j] doubleValue]/(pianoMax*pianoThreshold);
            [fullChroma replaceObjectAtIndex:j withObject:[NSNumber numberWithDouble:val]];
        }
    }
    
    chromaCounter = 62; // The data lags behind the audio, so give it a head start
    
    NSLog(@"Chroma data loaded.");
}

- (void)setWheelAlphaWithChroma:(NSMutableArray *)bassChroma pianoChroma:(NSMutableArray *)pianoChroma trumpetChroma:(NSMutableArray *)trumpetChroma {
    
//    Array used to reorder outputs into circle of fifths
    int *order = calloc(12, sizeof(int));
    if (fifthsActive) {
        order[0] = 1;
        order[1] = 8;
        order[2] = 3;
        order[3] = 10;
        order[4] = 5;
        order[5] = 12;
        order[6] = 7;
        order[7] = 2;
        order[8] = 9;
        order[9] = 4;
        order[10] = 11;
        order[11] = 6;
    } else {
        order[0] = 1;
        order[1] = 2;
        order[2] = 3;
        order[3] = 4;
        order[4] = 5;
        order[5] = 6;
        order[6] = 7;
        order[7] = 8;
        order[8] = 9;
        order[9] = 10;
        order[10] = 11;
        order[11] = 12;
    }
    
    for (int i=0; i<[bassChroma count]; i++) {
        NSNumber* p = [pianoChroma objectAtIndex:(order[i]-1)];
        NSNumber* t = [trumpetChroma objectAtIndex:(order[i]-1)];
        NSNumber* b = [bassChroma objectAtIndex:(order[i]-1)];
        
        [[largeSegmentViews objectAtIndex:i] setAlpha:[t floatValue]];
        [[medSegmentViews objectAtIndex:i] setAlpha:[p floatValue]];
        [[smallSegmentViews objectAtIndex:i] setAlpha:[b floatValue]];
    }
    
}

- (void)updateWheels {
    //[self setWheelAlphaWithChroma:[bassChromaData objectAtIndex:chromaCounter] pianoChroma:[pianoChromaData objectAtIndex:chromaCounter] trumpetChroma:[trumpetChromaData objectAtIndex:chromaCounter]];
    
    if (chromaRunning) {
        NSData* buffer=[[NSData alloc] init];
        buffer = [client getCurrentData];
        NSMutableArray* trumpet = [[NSMutableArray alloc] init];
        NSMutableArray* piano = [[NSMutableArray alloc] init];
        NSMutableArray* bass = [[NSMutableArray alloc] init];
        //    NSMutableArray* drums = [[NSMutableArray alloc] init];
        
        int order[12];
        order[0] = 1;
        if([buffer length]>200)
        {
            float* jawnbytes = (float *) malloc (sizeof(float) * 250);
            [buffer getBytes:jawnbytes];
            for (int i=0; i<12; i++)
            {
                NSNumber *trumpetNum = [NSNumber numberWithFloat:jawnbytes[4+i]];
                NSNumber *pianoNum = [NSNumber numberWithFloat:jawnbytes[4+i+12]];
                NSNumber *bassNum = [NSNumber numberWithFloat:jawnbytes[4+i+12+12]];
                
                [trumpet addObject:trumpetNum];
                [piano addObject:pianoNum];
                [bass addObject:bassNum];
            }
            //		NSNumber *drumsNum = [NSNumber numberWithFloat:jawnbytes[4+12+12+12]];
            
        }
        
        [self setWheelAlphaWithChroma:bass pianoChroma:piano trumpetChroma:trumpet];
        
        //[self setWheelAlphaWithChroma:[bassChromaData objectAtIndex:chromaCounter] pianoChroma:[pianoChromaData objectAtIndex:chromaCounter] trumpetChroma:[trumpetChromaData objectAtIndex:chromaCounter]];
        
        chromaCounter++;
    }
}

- (void)startAudioAndAnimation {
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/16.0 target:self selector:@selector(updateWheels) userInfo:nil repeats:YES];
    //[audioPlayer play];
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    
    for (UITextField *field in textLabels) {
        [field removeFromSuperview];
    }
    
    textLabels = [[NSMutableArray alloc] init];
    NSLog(@"removed text labals");
    [self performSelectorOnMainThread:@selector(removeAllSubviews) withObject:nil waitUntilDone:YES];
    chromaInfo = [[ChromaInfoViewController alloc] initWithNibName:@"ChromaInfoViewController" bundle:nil];
    
//    picData = [[NSMutableData alloc] init];
////    NSURLRequest *picRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/chromaLabels.png"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
////    NSURLConnection *picConnection = [[NSURLConnection alloc] initWithRequest:picRequest delegate:self];
//    picConnection = nil;

    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	client = [appDelegate client];

//    labelView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 10, 252, 23)];
//    labelView.image = [UIImage imageNamed:@"chromaLabels.png"];
//    [self.view addSubview:labelView];
    
    
    
    [self setupWheels];        
    //[self loadAudio];
    //[self loadChromaData];
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIToolbar *navBar;
    if (screenBounds.size.height == 568) {
        navBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 504, 320, 44)];
    } else {
        navBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 416, 320, 44)];
    }
    [navBar setTintColor:[UIColor blackColor]];
    
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Back"                                            
                                   style:UIBarButtonItemStyleBordered 
                                   target:self 
                                   action:@selector(backPressed)];
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:backButton, nil];
    [navBar setItems:buttonArray];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton setAlpha:0.8];
    if (screenBounds.size.height == 568) {
        [infoButton setFrame:CGRectMake(285, 473, 25, 25)];
    } else {
        [infoButton setFrame:CGRectMake(285, 385, 25, 25)];
    }
    [infoButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:infoButton];
    
    
    UIColor *blueColor = [[UIColor alloc] initWithRed:0.1255 green:0.6275 blue:0.8667 alpha:1];
    UIColor *yellowColor = [[UIColor alloc] initWithRed:0.9882 green:0.6510 blue:0.2196 alpha:1];
    UIColor *pinkColor = [[UIColor alloc] initWithRed:0.9137 green:0.0000 blue:0.5059 alpha:1];
    
    UILabel *inst1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 106, 25)];
    inst1Label.textAlignment = UITextAlignmentCenter;
    inst1Label.text = [instruments objectAtIndex:0];
    inst1Label.textColor = blueColor;
    inst1Label.backgroundColor = [UIColor clearColor];
    inst1Label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:inst1Label];
    
    
    UILabel *inst2Label = [[UILabel alloc] initWithFrame:CGRectMake(106, 15, 106, 25)];
    inst2Label.text = [instruments objectAtIndex:1];
    inst2Label.textAlignment = UITextAlignmentCenter;
    inst2Label.textColor = yellowColor;
    inst2Label.backgroundColor = [UIColor clearColor];
    inst2Label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:inst2Label];
    
    UILabel *inst3Label = [[UILabel alloc] initWithFrame:CGRectMake(212, 15, 106, 25)];
    inst3Label.text = [instruments objectAtIndex:2];
    inst3Label.textAlignment = UITextAlignmentCenter;
    inst3Label.textColor = pinkColor;
    inst3Label.backgroundColor = [UIColor clearColor];
    inst3Label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:inst3Label];
    
    
    [self.view setNeedsDisplay];
    
    
    
}

-(void) infoPressed {
    [self.navigationController pushViewController:chromaInfo animated:YES];
}


-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [picData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    labelView.image = [UIImage imageWithData:picData];
    NSLog(@"setting to internet image");
}

-(void) viewDidAppear:(BOOL)animated {
    //[audioPlayer setCurrentTime:0.0];
    chromaCounter = 0;
    [self startAudioAndAnimation];
    
}

-(void) backPressed {
    
    //[audioPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewDidDisappear:(BOOL)animated {
    
    //[audioPlayer stop];
    [animationTimer invalidate];
    NSLog(@"View Did Disappear.");
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateChromaWheel:(NSDictionary *)parameters {
    
    parameters = [parameters objectForKey:@"Chroma"];
    
    if ([[parameters objectForKey:@"circleOfFifths"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        fifthsActive = YES;
        NSLog(@"circle of fifths active");
    } else {
        fifthsActive = NO;
        NSLog(@"circle of fifths not active");
    }
    
    NSString *instrumentation = [parameters objectForKey:@"instrumentation"];
    NSArray *parts = [instrumentation componentsSeparatedByString:@","];
    instruments = [[NSMutableArray alloc] init];
    for (int i =0;i<3;i++) {
        [instruments addObject:[parts objectAtIndex:i]];
    }
    
    if ([[parameters objectForKey:@"running"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        chromaRunning = YES;
    } else {
        chromaRunning = NO;
    }
}

-(void) addLabels {
    
    
    
    
}

-(void) removeAllSubviews {
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
