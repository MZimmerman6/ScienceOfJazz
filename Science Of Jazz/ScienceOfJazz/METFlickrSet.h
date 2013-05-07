//
//  METFlickrSet.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface METFlickrSet : NSObject {
    
    NSString *farm;
    NSString *userID;
    NSString *setID;
    NSString *primary;
    NSString *secret;
    NSString *server;
    NSString *title;
    NSString *description;
    int numPhotos;
    NSString *urlString;
    NSURL *thumbURL;
    BOOL photoLoaded;
    NSMutableData *thumbData;
    NSURLConnection *thumbConnection;
    NSURLRequest *thumbRequest;
    UIImage *thumbnail;
    BOOL connectCreated;
    BOOL connectFailed;
    BOOL pictureDone;
    
}

@property (strong, nonatomic) NSString *farm;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *setID;
@property (strong, nonatomic) NSString *primary;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property int numPhotos;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *thumbURL;
@property BOOL photoLoaded;
@property (strong, nonatomic) NSMutableData *thumbData;
@property (strong, nonatomic) NSURLConnection *thumbConnection;
@property (strong, nonatomic) NSURLRequest *thumbRequest;
@property (strong, nonatomic) UIImage *thumbnail;
@property BOOL connectCreated;
@property BOOL connectFailed;
@property BOOL pictureDone;

-(void) processThumbImage;
@end
