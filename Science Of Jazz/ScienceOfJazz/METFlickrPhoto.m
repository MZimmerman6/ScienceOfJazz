//
//  METFlickrPhoto.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METFlickrPhoto.h"

@implementation METFlickrPhoto

@synthesize server,secret,title,photoID,picture,isPrimary,photoData, farm, thumbData, thumbFailed, photoFailed;
@synthesize photoRequest, photoConnection,photo,connectionFailed,connectionCreated, thumbDone, photoDone;
@synthesize photoURL,photoURLString,thumbURL,thumbnail,thumbRequest,thumbURLString,thumbConnection;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

@end
