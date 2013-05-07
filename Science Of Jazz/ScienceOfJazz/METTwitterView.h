//
//  METTwitterView.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METTweet.h"

@protocol METTwitterViewDelegate;

@interface METTwitterView : UIView <NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    
    NSMutableArray *tweetArray;
    NSMutableData *twitData;
    id <METTwitterViewDelegate> delegate;
    NSURLRequest *twitRequest;
    NSURLConnection *twitConnection;
    
    UIImageView *twitterFrame;
    UIImageView *userPicView;
    UILabel *userNameLabel;
    UITextView *tweetTextView;
    NSURL *twitURL;
    BOOL newTweets;
    int tweetIndex;
    METTweet *currentTweet;
    NSTimer *tweetTimer;
    NSTimer *getNewTweetTimer;
}

@property (strong, nonatomic) NSMutableArray *tweetArray;
@property (strong, nonatomic) NSMutableData *twitData;
@property (strong, nonatomic) NSURL *twitURL;

-(id) initWithUserName:(NSString*)userName andFrame:(CGRect)frame andDelegate:(id)twitDelegate;

-(id) initWithHashTag:(NSString*)hashTag andFrame:(CGRect)frame andDelegate:(id)twitDelegate;

-(void) processTwitterData;

-(void) placeObjectsInView;

-(void) updateTweetToIndex:(int)index;

-(void) getNewTweets;

-(void) nextTweet;

-(void) invalidateTimers;

-(void) startTimersWithDelegate:(id)timerDelegate;


@end

@protocol METTwitterViewDelegate

@optional

-(void) didSwitchToNextTweet;

@end
