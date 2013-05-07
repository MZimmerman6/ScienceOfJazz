//
//  ChromaInfoViewController.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChromaInfoViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    NSMutableData *infoData;
    IBOutlet UIWebView *infoView;
    
}

-(IBAction)backPressed:(id)sender;



@end
