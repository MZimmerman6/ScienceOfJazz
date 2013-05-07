//
//  METYoutubeView.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METYoutubeVideo.h"

@protocol METYoutubeViewDelegate;

@interface METYoutubeView : UIView <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *videoTable;
    NSMutableArray *videoArray;
    NSURLConnection *pageConnection;
    NSMutableData *pageData;
    NSURL *playlistURL;
    BOOL userChosen;
    BOOL playlistChosen;
    id <METYoutubeViewDelegate> delegate;
    
}

@property (strong, nonatomic) UITableView *videoTable;
@property (strong, nonatomic) NSMutableArray *videoArray;

-(id) initWithUserVideos:(NSString*)userName andFrame:(CGRect)frame andDelegate:(id)ytDelegate;

-(id) initWithUserPlaylist:(NSString*)playListCode andFrame:(CGRect)frame andDelegate:(id)ytDelegate;

-(void) processUserVideoData;

-(void) processPlaylistVideoData;

-(void) doneGettingYoutubeVideos;

-(BOOL) doneGettingPictures;

@end

@protocol METYoutubeViewDelegate <NSObject>

-(void) didSelectVideo:(METYoutubeVideo*)video atIndex:(int)index;

@optional

-(void) startActivityIndicator;

-(void) stopActivityIndicator;

-(void) allVideoDataLoaded;

@end
