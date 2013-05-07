//
//  METTweet.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface METTweet : NSObject {
    
    NSString *userName;
    NSString *text;
    NSURL *picURL;
    NSString *picURLString;
    NSURLRequest *picRequest;
    NSURLConnection *picConnection;
    BOOL connectionStarted;
    BOOL gotPicture;
    BOOL connectionDone;
    NSMutableData *picData;
    UIImage *userPicture;
}

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *picURL;
@property (nonatomic, strong) NSString *picURLString;
@property (strong, nonatomic) NSURLRequest *picRequest;
@property (strong, nonatomic) NSURLConnection *picConnection;
@property BOOL connectionStarted;
@property BOOL gotPicture;
@property BOOL connectionDone;
@property (strong, nonatomic) NSMutableData *picData;
@property (strong, nonatomic) UIImage *userPicture;


-(void) processUserImage;

-(void) setupURL:(NSString*)urlString;

@end
