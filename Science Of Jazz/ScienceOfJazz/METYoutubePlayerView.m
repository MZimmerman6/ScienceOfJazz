//
//  METYoutubePlayerView.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METYoutubePlayerView.h"

@implementation METYoutubePlayerView

@synthesize userLabel, ratingLabel, descriptionTV, timeLabel, titleText, viewsLabel, thumbView, videoView, video;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithVideo:(METYoutubeVideo*)vid andFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    titleText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    titleText.scrollEnabled = NO;
    titleText.userInteractionEnabled = NO;
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.userInteractionEnabled = NO;
    
    ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    ratingLabel.backgroundColor = [UIColor clearColor];
    ratingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    ratingLabel.userInteractionEnabled = NO;
    
    viewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    viewsLabel.backgroundColor = [UIColor clearColor];
    viewsLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    viewsLabel.userInteractionEnabled = NO;
    
    userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    userLabel.userInteractionEnabled = NO;
    
    descriptionTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    descriptionTV.backgroundColor = [UIColor clearColor];
    descriptionTV.font = [UIFont fontWithName:@"Helvetica" size:12];
    descriptionTV.scrollEnabled = YES;
    descriptionTV.userInteractionEnabled = YES;
    
    thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    thumbView.image = [UIImage imageNamed:@"thumbup.png"];
    
    videoView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 62-44, 280, 184)];
    videoView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:titleText];
    [self addSubview:timeLabel];
    [self addSubview:ratingLabel];
    [self addSubview:viewsLabel];
    [self addSubview:userLabel];
    [self addSubview:descriptionTV];
    [self addSubview:thumbView];
    [self addSubview:videoView];
    
    [self setVideo:vid];
    [self loadVideo];
    [self loadVideoDetails];
    
    return self;
}

-(void) loadVideo {
    NSString *videoURLString = [video videoURLString];
    @autoreleasepool {
        NSString *htmlString = @"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 212\"/></head><body style=\"background:#000;margin-top:0px;margin-left:0px\"><div><object width=\"320\" height=\"210\"><param name=\"movie\" value=\"http://www.youtube.com/v/q5WBsBDXqDs?version=3&amp;hl=en_US&amp;rel=0\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"%@?version=3&amp;hl=en_US&amp;rel=0\" type=\"application/x-shockwave-flash\" width=\"%i\" height=\"%i\" allowscriptaccess=\"always\" allowfullscreen=\"true\"></embed></object></div></body></html>";
        htmlString = [NSString stringWithFormat:htmlString,videoURLString,(int)self.videoView.frame.size.width, (int)self.videoView.frame.size.height];
        [videoView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://jazz.ece.drexel.edu/PhillyScience"]];
    }
    [videoView setNeedsDisplay];
    
}


-(void) loadVideoDetails {
    
    [self removeInfoSubviews];
    int startY = 206;
    
    titleText.text = video.title;
    titleText.frame = CGRectMake(0, startY, 320, 100);
    [self addSubview:titleText];
    CGRect titleFrame = titleText.frame;
    titleFrame.size.height = titleText.contentSize.height;
    titleText.frame = titleFrame;
    startY += (titleFrame.size.height - 5);
    
    userLabel.text = video.author;
    userLabel.frame = CGRectMake(10, startY, 320, 20);
    [self addSubview:userLabel];
    
    viewsLabel.text = [NSString stringWithFormat:@"%i views",video.numViews];
    viewsLabel.frame = CGRectMake(0, startY, 300, 20);
    viewsLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:viewsLabel];
    
    startY += 20;
    
    timeLabel.text = video.timeString;
    timeLabel.frame = CGRectMake(10, startY, 300, 20);
    [self addSubview:timeLabel];
    
    ratingLabel.text = [NSString stringWithFormat:@"%i%%",video.rating];
    ratingLabel.frame = CGRectMake(0, startY, 300, 20);
    ratingLabel.textAlignment = UITextAlignmentRight;
    [self addSubview:ratingLabel];
    
    thumbView.frame = CGRectMake(245, startY-5, 21, 21);
    if (video.rating >= 50) {
        thumbView.image = [UIImage imageNamed:@"thumbup.png"];
    } else {
        thumbView.image = [UIImage imageNamed:@"thumbdown.png"];
    }
    [self addSubview:thumbView];
    
    
    startY += 15;
    descriptionTV.frame = CGRectMake(0,startY, 320, 460-startY-10);
    descriptionTV.text = video.description;
    [self addSubview:descriptionTV];
    
}

-(void) removeInfoSubviews {
    
    [titleText removeFromSuperview];
    [timeLabel removeFromSuperview];
    [ratingLabel removeFromSuperview];
    [viewsLabel removeFromSuperview];
    [userLabel removeFromSuperview];
    [descriptionTV removeFromSuperview];
    [thumbView removeFromSuperview];
    
}

@end
