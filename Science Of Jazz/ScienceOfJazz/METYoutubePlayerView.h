//
//  METYoutubePlayerView.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METYoutubeVideo.h"

@protocol METYoutubePlayerViewDelegate;

@interface METYoutubePlayerView : UIView {
    
    UIWebView *videoView;
    METYoutubeVideo *video;
    
    UITextView *titleText;
    UILabel *timeLabel;
    UILabel *ratingLabel;
    UILabel *userLabel;
    UILabel *viewsLabel;
    UITextView *descriptionTV;
    UIImageView *thumbView;
    id <METYoutubePlayerViewDelegate> delegate;
    
}

@property (nonatomic, retain) UIWebView *videoView;
@property (nonatomic, retain) METYoutubeVideo *video;
@property (nonatomic, retain) UITextView *titleText;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *ratingLabel;
@property (nonatomic, retain) UILabel *userLabel;
@property (nonatomic, retain) UILabel *viewsLabel;
@property (nonatomic, retain) UITextView *descriptionTV;
@property (nonatomic, retain) UIImageView *thumbView;

-(id) initWithVideo:(METYoutubeVideo*)vid andFrame:(CGRect)frame;

-(void) loadVideoDetails;

-(void) loadVideo;

-(void) removeInfoSubviews;

@end


@protocol METYoutubePlayerViewDelegate

@optional

-(void) videoDidStartPlaying;

@end