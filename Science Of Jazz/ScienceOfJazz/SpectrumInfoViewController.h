//
//  SpectrumInfoViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpectrumInfoViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    NSMutableData *infoData;
    IBOutlet UIWebView *infoView;
}

@property (strong, nonatomic) IBOutlet UIWebView *infoView;

-(IBAction)backPressed:(id)sender;

@end
