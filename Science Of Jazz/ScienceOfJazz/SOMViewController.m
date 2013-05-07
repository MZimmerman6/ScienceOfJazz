//
//  SOMViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SOMViewController.h"
#import "METFrameworks.h"
#import "Localization.h"


@interface SOMViewController ()

@end

@implementation SOMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstOpen = YES;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568) {
        chromaViewController = [[ChromaWheelViewController alloc] initWithNibName:@"ChromaWheelViewController_iPhone5" bundle:nil];
        spectrumViewController = [[SpectrumViewController alloc] initWithNibName:@"SpectrumViewController" bundle:nil];
        soundFieldViewController = [[SoundFieldViewController alloc] initWithNibName:@"SoundFieldViewController_iPhone5" bundle:nil];
        somInfoViewController = [[SOMInformationViewController alloc] initWithNibName:@"SOMInformationViewController" bundle:nil];
        takeOverViewController = [[TakeOverViewController alloc] initWithNibName:@"TakeOverViewController_iPhone5" bundle:nil];
    } else {
        chromaViewController = [[ChromaWheelViewController alloc] initWithNibName:@"ChromaWheelViewController" bundle:nil];
        spectrumViewController = [[SpectrumViewController alloc] initWithNibName:@"SpectrumViewController" bundle:nil];
        soundFieldViewController = [[SoundFieldViewController alloc] initWithNibName:@"SoundFieldViewController" bundle:nil];
        somInfoViewController = [[SOMInformationViewController alloc] initWithNibName:@"SOMInformationViewController" bundle:nil];
        takeOverViewController = [[TakeOverViewController alloc] initWithNibName:@"TakeOverViewController" bundle:nil];
    }
}

-(IBAction)infoPressed:(id)sender {
    
    [self.navigationController pushViewController:somInfoViewController animated:YES];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate setSomLoaded:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate updateFromServers];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}
-(void) viewDidDisappear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)chromaPressed:(id)sender {
    [self.navigationController pushViewController:chromaViewController animated:YES];
}

-(IBAction)spectrumPressed:(id)sender {
    [self.navigationController pushViewController:spectrumViewController animated:YES];
}

-(IBAction)soundfieldPressed:(id)sender {
    
    [self.navigationController pushViewController:soundFieldViewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateChromaViewController:(NSDictionary *)parameters {
    
//    CGRect bounds = [[UIScreen mainScreen] bounds];
    [chromaViewController updateChromaWheel:parameters];
    NSLog(@"%@",parameters);
}

-(void) updateSpectrumViewController:(NSDictionary *)parameters {
    
    [spectrumViewController updateSpectrumParameters:parameters];
}

-(void) updateSoundFieldPower:(float)power {
    [soundFieldViewController setAudioPower:power];
}

-(void) updateSoundFieldBackground:(UIImage *)image {
    [soundFieldViewController updateBackgroundImage:image];
}

-(void) updateSoundFieldOverlayShift:(int)shift andScaling:(int)scaling {
    [soundFieldViewController updateSoundFieldOverlayShift:shift andScaling:scaling];
}

-(void) pushTakeOverController {
    
    [self.navigationController pushViewController:takeOverViewController animated:NO];
}

-(void) removeTakeOverController {
    [takeOverViewController removeFromView];
}

-(void) updateTakeoverScreenWithColor:(UIColor *)color {
    [takeOverViewController updateScreenToColor:color];
}

-(void) updateSoundFieldUserLocation:(CGPoint)point {
    [soundFieldViewController updateUserBlob:point];
}

@end
