//
//  SOMInformationViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SOMInformationViewController.h"

@interface SOMInformationViewController ()

@end

@implementation SOMInformationViewController

@synthesize infoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    infoData = [[NSMutableData alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void) viewWillAppear:(BOOL)animated {
    infoData = [[NSMutableData alloc] init];
 //    NSURLRequest *infoRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/info.html"]];
    NSURLRequest *infoRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/ScienceOfJazz/Info/info.html"] 
                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                  timeoutInterval:4];
    NSURLConnection *infoConnection = [[NSURLConnection alloc] initWithRequest:infoRequest delegate:self];
    infoConnection = nil;
}


-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [infoData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"webview failed");
    NSString* path = [[NSBundle mainBundle] pathForResource:@"SOMInfoError" 
                                                     ofType:@"html"];
    NSData *backupInfoData = [NSData dataWithContentsOfFile:path];
    NSString *infoString = [[NSString alloc] initWithData:backupInfoData encoding:NSUTF8StringEncoding];
    [infoView loadHTMLString:infoString baseURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/"]];
    
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *htmlString = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    [infoView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience/ScienceOfMusic/"]];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
//    NSLog(@"webview failed");
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"SOMInfoError" 
//                                                     ofType:@"html"];
//    NSData *infoData = [NSData dataWithContentsOfFile:path];
//    NSString *infoString = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
//    [infoView loadHTMLString:infoString baseURL:[NSURL URLWithString:@"http://drexel.edu"]];
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
