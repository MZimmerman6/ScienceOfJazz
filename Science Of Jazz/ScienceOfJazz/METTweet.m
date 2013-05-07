//
//  METTweet.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "METTweet.h"

@implementation METTweet

@synthesize picURL, picURLString,userName,text,picRequest, picConnection;
@synthesize connectionDone, connectionStarted, gotPicture, picData, userPicture;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    picData = [[NSMutableData alloc] init];
    return self;
}

-(void) setupURL:(NSString*)urlString {
    
    picURLString = urlString;
    picURL = [[NSURL alloc] initWithString:urlString];
    
}

-(void) processUserImage {
    
    userPicture = [UIImage imageWithData:picData];
    gotPicture = YES;
}

@end
