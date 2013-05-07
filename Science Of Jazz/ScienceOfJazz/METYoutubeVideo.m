//
//  METYoutubeVideo.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METYoutubeVideo.h"

@implementation METYoutubeVideo

@synthesize thumbnailURL, videoURL, timeString, author, length, picture, title, numViews, rating;
@synthesize description, thumbData, thumbConnection, gotPicture, thumbRequest, connectionStarted;
@synthesize connectionDone;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }    
    gotPicture = NO;
    thumbData = [[NSMutableData alloc] init];
    return self;
}

-(NSString*) videoURLString {
    return [NSString stringWithFormat:@"%@",videoURL];
}

-(NSString*) thumbnailURLString {
    return [NSString stringWithFormat:@"%@",thumbnailURL];
}

-(void) processPicture {
//    NSLog(@"Processing Picture");
    self.gotPicture = YES;
    self.picture = [UIImage imageWithData:thumbData];
    self.connectionDone = YES;
}

@end
