//
//  TakeOverViewController.m
//  ScienceOfJazz
//
//  Created by Matthew Zimmerman on 4/16/13.
//
//

#import "TakeOverViewController.h"

@interface TakeOverViewController ()

@end

@implementation TakeOverViewController

@synthesize colorOverlay;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) removeFromView {
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) updateScreenToColor:(UIColor *)color {
    [UIView beginAnimations:@"MoveAndStretch" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [colorOverlay setBackgroundColor:color];
    [UIView commitAnimations];
}

@end
