//
//  SoundBlob.m
//  SoundField
//
//  Created by Brian Dolhansky on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserBlobs.h"
#define SIZE 100
#define ANIMATION_TIME 0.5

@implementation UserBlobs

- (id)initWithX:(CGFloat)newX y:(CGFloat)newY {
    self = [super init];
    
    x = newX-SIZE/2;
    y = newY-SIZE/2;
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)changeIntensity:(CGFloat)newIntensity {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_TIME];
    [blobView setAlpha:newIntensity];
    [UIView commitAnimations];
    intensity = (double)newIntensity;
}

- (int)getX {
    return (int)x;
}

- (int)getY {
    return (int)y;
}

-(double)getIntensity {
    return intensity;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    blobView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserBlob.png"]];
    [blobView setFrame:CGRectMake(x, y, SIZE, SIZE)];
    [[self view] addSubview:blobView];
    [self.view setUserInteractionEnabled:NO];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
