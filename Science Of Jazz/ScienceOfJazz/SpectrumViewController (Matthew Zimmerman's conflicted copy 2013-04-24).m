//
//  SpectrumViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpectrumViewController.h"
#import "GLView.h"


@interface SpectrumViewController ()

@end

@implementation SpectrumViewController

@synthesize glView,window, glViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            glView = [[GLView alloc] initWithFrame:CGRectMake(0, -20, 320, 568)];
            window = [[UIWindow alloc] initWithFrame:CGRectMake(0, -20, 320, 568)];
        } else {
            glView = [[GLView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
            window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        }
        [glView setBackgroundColor:[UIColor blueColor]];
        
        glViewController = [[GLViewController alloc] init];
        [glView setDelegate:glViewController];
        [self.view addSubview:glView];
        numTouches = 0;
        spectrumRunning = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spectrumInfo = [[SpectrumInfoViewController alloc] initWithNibName:@"SpectrumInfoViewController" bundle:nil];
    picData = [[NSMutableData alloc] init];
    barAdded = NO;
    firstView = YES;
    counter = 0;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 568, 44)];
    } else {
        bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    }
    bottomBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle:@"Back"                                            
                                   style:UIBarButtonItemStyleBordered 
                                   target:self 
                                   action:@selector(backPressed)];
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:backButton, nil];
    [bottomBar setItems:buttonArray];
    bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
    
//    
//    labelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 390, 25)];
//    labelView.image = [UIImage imageNamed:@"spectrumLabels.png"];
    
    UIColor *blueColor = [[UIColor alloc] initWithRed:0.1255 green:0.6275 blue:0.8667 alpha:1];
    UIColor *yellowColor = [[UIColor alloc] initWithRed:0.9882 green:0.6510 blue:0.2196 alpha:1];
    UIColor *pinkColor = [[UIColor alloc] initWithRed:0.9137 green:0.0000 blue:0.5059 alpha:1];
    UIColor *greenColor = [[UIColor alloc] initWithRed:0.0157 green:0.6118 blue:0.2784 alpha:1];
    
    if (screenBounds.size.height == 568) {
        inst1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 142, 25)];
        inst2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 142, 25)];
        inst3Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 142, 25)];
        inst4Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 142, 25)];
    } else {
        inst1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 25)];
        inst2Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 25)];
        inst3Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 25)];
        inst4Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 25)];
    }
    inst1Label.text = @"Sax";
    inst1Label.textAlignment = UITextAlignmentCenter;
    inst1Label.font = [UIFont systemFontOfSize:20];
    inst1Label.backgroundColor = [UIColor clearColor];
    inst1Label.textColor = blueColor;
    
    inst2Label.text = @"Keys";
    inst2Label.textAlignment = UITextAlignmentCenter;
    inst2Label.font = [UIFont systemFontOfSize:20];
    inst2Label.backgroundColor = [UIColor clearColor];
    inst2Label.textColor = yellowColor;
    
    inst3Label.text = @"Bass";
    inst3Label.textAlignment = UITextAlignmentCenter;
    inst3Label.font = [UIFont systemFontOfSize:20];
    inst3Label.backgroundColor = [UIColor clearColor];
    inst3Label.textColor = pinkColor;
    
    inst4Label.text = @"Drums";
    inst4Label.textAlignment = UITextAlignmentCenter;
    inst4Label.font = [UIFont systemFontOfSize:20];
    inst4Label.backgroundColor = [UIColor clearColor];
    inst4Label.textColor = greenColor;
    
    infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton setAlpha:0.8];
    [infoButton setFrame:CGRectMake(0, 0, 25, 25)];
    [infoButton addTarget:self action:@selector(infoPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:infoButton];
    
}

-(void) viewDidAppear:(BOOL)animated {
    
    timerRunning = NO;
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:YES];
    glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
    
    if (!barAdded) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            landscapeTransform = CGAffineTransformTranslate( landscapeTransform, 242, 260.0 );
            [bottomBar setTransform:landscapeTransform];
            [self.view addSubview:bottomBar];
            
            CGAffineTransform picLandscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            picLandscapeTransform = CGAffineTransformTranslate(picLandscapeTransform, 245, -85.0 );
            [labelView setTransform:picLandscapeTransform];
            [self.view addSubview:labelView];
            
            CGAffineTransform infoLandscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            infoLandscapeTransform = CGAffineTransformTranslate(infoLandscapeTransform, 505, -55.0 );
            [infoButton setTransform:infoLandscapeTransform];
            [self.view addSubview:infoButton];
            
            CGAffineTransform instLabel1Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel1Trans = CGAffineTransformTranslate(instLabel1Trans, 50, -205.0 );
            [inst1Label setTransform:instLabel1Trans];
            [self.view addSubview:inst1Label];
//
            
            CGAffineTransform instLabel2Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel2Trans = CGAffineTransformTranslate(instLabel2Trans, 170, -205.0 );
            [inst2Label setTransform:instLabel2Trans];
            [self.view addSubview:inst2Label];
            
            CGAffineTransform instLabel3Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel3Trans = CGAffineTransformTranslate(instLabel3Trans, 290, -205.0 );
            [inst3Label setTransform:instLabel3Trans];
            [self.view addSubview:inst3Label];
            
            CGAffineTransform instLabel4Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel4Trans = CGAffineTransformTranslate(instLabel4Trans, 410, -205.0 );
            [inst4Label setTransform:instLabel4Trans];
            [self.view addSubview:inst4Label];
//            
//            [self.view addSubview:inst1Label];
//            [self.view addSubview:inst2Label];
//            [self.view addSubview:inst3Label];
//            [self.view addSubview:inst4Label];
            
            
        } else {
            CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            landscapeTransform = CGAffineTransformTranslate( landscapeTransform, 200, 220.0 );
            [bottomBar setTransform:landscapeTransform];
            [self.view addSubview:bottomBar];
            
            CGAffineTransform picLandscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            picLandscapeTransform = CGAffineTransformTranslate(picLandscapeTransform, 195, -85.0 );
            [labelView setTransform:picLandscapeTransform];
            [self.view addSubview:labelView];
            
            CGAffineTransform infoLandscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            infoLandscapeTransform = CGAffineTransformTranslate(infoLandscapeTransform, 430, -45.0 );
            [infoButton setTransform:infoLandscapeTransform];
            [self.view addSubview:infoButton];
            
            CGAffineTransform instLabel1Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel1Trans = CGAffineTransformTranslate(instLabel1Trans, 40, -220.0 );
            [inst1Label setTransform:instLabel1Trans];
            [self.view addSubview:inst1Label];
            //
            
            CGAffineTransform instLabel2Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel2Trans = CGAffineTransformTranslate(instLabel2Trans, 150, -220.0 );
            [inst2Label setTransform:instLabel2Trans];
            [self.view addSubview:inst2Label];
            
            CGAffineTransform instLabel3Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel3Trans = CGAffineTransformTranslate(instLabel3Trans, 260, -220.0 );
            [inst3Label setTransform:instLabel3Trans];
            [self.view addSubview:inst3Label];
            
            CGAffineTransform instLabel4Trans = CGAffineTransformMakeRotation( 90.0 * M_PI / 180.0 );
            instLabel4Trans = CGAffineTransformTranslate(instLabel4Trans, 355, -220.0 );
            [inst4Label setTransform:instLabel4Trans];
            [self.view addSubview:inst4Label];
            
        }
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [picData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    labelView.image = [UIImage imageWithData:picData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touch started");
    numTouches += [touches count];
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended");
    [bottomBar setAlpha:1];
    
}

-(void) backPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated {
//    [self.view addSubview:glView];
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated:YES];
}


-(void) infoPressed {
    [self.navigationController pushViewController:spectrumInfo animated:YES];
}

-(void) doneFadingToolbar {
    [tapTimer invalidate];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [tapTimer invalidate];
    timerRunning = NO;
    [glView stopAnimation];
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:YES];
}

-(void) viewDidDisappear:(BOOL)animated {
//    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated:YES];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void) updateSpectrumParameters:(NSDictionary *)parameters {
    
    instruments = [[[parameters objectForKey:@"Spectrum"] objectForKey:@"instrumentation"] componentsSeparatedByString:@","];
    inst1Label.text = [instruments objectAtIndex:0];
    inst2Label.text = [instruments objectAtIndex:1];
    inst3Label.text = [instruments objectAtIndex:2];
    inst4Label.text = [instruments objectAtIndex:3];
    [self.view setNeedsDisplay];
    
    if ([[[parameters objectForKey:@"Spectrum"] objectForKey:@"running"] caseInsensitiveCompare:@"true"] == NSOrderedSame) {
        [glViewController startSpectrum];
    } else {
        [glViewController stopSpectrum];
    }
    
    
}

@end
