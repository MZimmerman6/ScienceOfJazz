//
//  METFlickrPhoto.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface METFlickrPhoto : NSObject {
    
    NSString *photoID;
    NSString *secret;
    NSString *server;
    NSString *title;
    NSString *isPrimary;
    NSString *farm;
    NSMutableData *photoData;
    NSMutableData *thumbData;
    UIImage *picture;
    NSURLConnection *photoConnection;
    NSURLRequest *photoRequest;
    NSURLConnection *thumbConnection;
    NSURLRequest *thumbRequest;
    BOOL connectionCreated;
    BOOL connectionFailed;
    UIImage *photo;
    UIImage *thumbnail;
    NSURL *photoURL;
    NSString *photoURLString;
    NSURL *thumbURL;
    NSString *thumbURLString;
    BOOL thumbDone;
    BOOL photoDone;
    BOOL thumbFailed;
    BOOL photoFailed;
}


@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *farm;
@property (strong, nonatomic) NSString *isPrimary;
@property (strong, nonatomic) NSMutableData *photoData;
@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) NSURLRequest *photoRequest;
@property (strong, nonatomic) NSURLConnection *photoConnection;
@property (strong, nonatomic) NSURLRequest *thumbRequest;
@property (strong, nonatomic) NSURLConnection *thumbConnection;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) UIImage *thumbnail;
@property BOOL connectionFailed;
@property BOOL connectionCreated;
@property (strong, nonatomic) NSURL *photoURL;
@property (strong, nonatomic) NSString *photoURLString;
@property (strong, nonatomic) NSURL *thumbURL;
@property (strong, nonatomic) NSString *thumbURLString;
@property (strong, nonatomic) NSMutableData *thumbData;
@property BOOL thumbDone;
@property BOOL photoDone;
@property BOOL thumbFailed;
@property BOOL photoFailed;

@end
