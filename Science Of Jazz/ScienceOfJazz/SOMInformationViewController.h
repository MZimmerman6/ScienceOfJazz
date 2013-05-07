//
//  SOMInformationViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOMInformationViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    IBOutlet UIWebView *infoView;
    NSMutableData *infoData;
}

@property (strong, nonatomic) IBOutlet UIWebView *infoView;

-(IBAction)backPressed:(id)sender;


@end
