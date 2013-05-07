//
//  METYoutubeVideo.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface METYoutubeVideo : NSObject {
    
    NSURL *thumbnailURL;
    NSURL *videoURL;
    NSString *timeString;
    NSString *author;
    int length;
    UIImage *picture;
    NSString *title;
    int numViews;
    int rating;
    NSString *description;
    NSURLRequest *thumbRequest;
    NSURLConnection *thumbConnection;
    BOOL connectionStarted;
    BOOL connectionDone;
    
    NSMutableData *thumbData;
    BOOL gotPicture;
    
}

@property (nonatomic, retain) NSURL *thumbnailURL;
@property (nonatomic, retain) NSURL *videoURL;
@property (nonatomic, retain) NSString *timeString;
@property (nonatomic, retain) NSString *author;
@property int length;
@property (nonatomic, retain) UIImage *picture;
@property (nonatomic, retain) NSString *title;
@property int numViews;
@property int rating;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSURLConnection *thumbConnection;
@property (nonatomic, retain) NSURLRequest *thumbRequest;
@property (strong, nonatomic) NSMutableData *thumbData;
@property BOOL gotPicture;
@property BOOL connectionStarted;
@property BOOL connectionDone;

-(NSString*) videoURLString;

-(NSString*) thumbnailURLString;

-(void) processPicture;

@end
