//
//  SoundFieldInfoViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundFieldInfoViewController.h"

@interface SoundFieldInfoViewController ()

@end

@implementation SoundFieldInfoViewController

@synthesize infoView;

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
    infoData = [[NSMutableData alloc] init];
    // Do any additional setup after loading the view from its nib.

}

-(void) viewWillAppear:(BOOL)animated {
    
    infoData = [[NSMutableData alloc] init];
    NSURL *infoURL = [NSURL URLWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Info/soundfield.html"];
    NSURLRequest *infoRequest = [[NSURLRequest alloc] initWithURL:infoURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:4];
    NSURLConnection *infoConnection = [[NSURLConnection alloc] initWithRequest:infoRequest delegate:self];
    infoConnection = nil;
    
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [infoData appendData:data];
    
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *htmlString = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    [infoView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/"]];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"soundfieldError" 
                                                     ofType:@"html"];
    NSData *backupInfoData = [NSData dataWithContentsOfFile:path];
    NSString *infoString = [[NSString alloc] initWithData:backupInfoData encoding:NSUTF8StringEncoding];
    [infoView loadHTMLString:infoString baseURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/"]];
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
