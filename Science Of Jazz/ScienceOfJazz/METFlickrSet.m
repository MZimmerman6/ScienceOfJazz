//
//  METFlickrSet.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METFlickrSet.h"

@implementation METFlickrSet

@synthesize farm,setID,title,secret,server,userID,primary,description, numPhotos;
@synthesize urlString, thumbURL, thumbData, photoLoaded, thumbRequest, thumbConnection;
@synthesize thumbnail, connectCreated, connectFailed, pictureDone;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    thumbData = [[NSMutableData alloc] init];
    return self;
}


-(void) processThumbImage {
    thumbnail = [UIImage imageWithData:thumbData];
    pictureDone = YES;
}

@end
