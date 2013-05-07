//
//  METTwitterView.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "METTwitterView.h"
#import "METTweet.h"

NSString const *hashtagURL = @"http://search.twitter.com/search.json?q=%23";

@implementation METTwitterView

@synthesize tweetArray, twitData, twitURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) placeObjectsInView {
    
    twitterFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 271, 148)];
    userPicView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 79, 55, 55)];
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(83, 14, 178, 28)];
    tweetTextView = [[UITextView alloc] initWithFrame:CGRectMake(79, 40, 178, 89)];
    
    userPicView.image = [UIImage imageNamed:@"camera.png"];
    twitterFrame.image = [UIImage imageNamed:@"twitterBox.png"];
    
    [tweetTextView setEditable:NO];
    [tweetTextView setBackgroundColor:[UIColor clearColor]];
    [tweetTextView setDataDetectorTypes:UIDataDetectorTypeLink];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setTextColor:[UIColor whiteColor]];
    
    [userPicView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:twitterFrame];
    [self addSubview:userPicView];
    [self addSubview:userNameLabel];
    [self addSubview:tweetTextView];
    
}

-(id) initWithHashTag:(NSString *)hashTag andFrame:(CGRect)frame andDelegate:(id)twitDelegate {
    
    self = [super initWithFrame:frame];
    delegate = twitDelegate;
    twitData = [[NSMutableData alloc] init];
    
    NSURL *twitterURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",hashtagURL,hashTag]];
    [self setTwitURL:twitterURL];
    twitURL = twitterURL;
    [self placeObjectsInView];
    [self getNewTweets];
    
    return self;
}

-(id) initWithUserName:(NSString *)userName andFrame:(CGRect)frame andDelegate:(id)twitDelegate {
    
    self = [super initWithFrame:frame];
    return self;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == twitConnection) {
        [twitData appendData:data];
//        NSLog(@"got tweet data");
    } else if (connection == [currentTweet picConnection]){
        [[currentTweet picData] appendData:data];
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == twitConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Unable to reach Twitter servers. Please try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == twitConnection) {
        [self processTwitterData];
        [self nextTweet];
    } else if (connection == [currentTweet picConnection]){
        [currentTweet processUserImage];
        userPicView.image = [currentTweet userPicture];
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
}

-(void) processTwitterData {
    
    NSDictionary *tweetDictionary = [NSJSONSerialization JSONObjectWithData:twitData 
                                                                    options:NSJSONReadingAllowFragments 
                                                                      error:nil];
    tweetDictionary = [tweetDictionary objectForKey:@"results"];
//    NSLog(@"%@",tweetDictionary);
    METTweet *tempTweet;
    tweetArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        for (NSDictionary *result in tweetDictionary) {
            tempTweet = [[METTweet alloc] init];
            [tempTweet setText:[result objectForKey:@"text"]];
            [tempTweet setupURL:[result objectForKey:@"profile_image_url"]];
            [tempTweet setUserName:[result objectForKey:@"from_user"]];
            [tweetArray addObject:tempTweet];
        }
    }
    [self startTimersWithDelegate:self];
    
    
}

-(void) updateTweetToIndex:(int)index {
    
    @autoreleasepool {
        @try {
        currentTweet = (METTweet*)[tweetArray objectAtIndex:index];
//        NSLog(@"%@",[currentTweet userName]);
        [currentTweet setPicRequest:[[NSURLRequest alloc] initWithURL:[currentTweet picURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10]];
        [currentTweet setPicConnection:[[NSURLConnection alloc] initWithRequest:[currentTweet picRequest] delegate:self]];
        userNameLabel.text = [NSString stringWithFormat:@"@%@",[currentTweet userName]];
        tweetTextView.text = [currentTweet text];
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        } @catch (NSException *nse) {}
    }
    
}

-(void) getNewTweets {
    
    [self invalidateTimers];
    twitData = [[NSMutableData alloc] init];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    twitRequest = nil;
    twitConnection = nil;
    
    twitRequest = [[NSURLRequest alloc] initWithURL:twitURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:6];
    twitConnection = [[NSURLConnection alloc] initWithRequest:twitRequest delegate:self];
    tweetIndex = 0;
    newTweets = YES;
    
}

-(void) nextTweet {
        
    if (newTweets) {
        newTweets = NO;
        tweetIndex = 0;
    } else {
        tweetIndex = (tweetIndex+1)%[tweetArray count];
    }
//    NSLog(@"nextTweet");
    [self updateTweetToIndex:tweetIndex];
}

-(void) startTimersWithDelegate:(id)timerDelegate {
    
//    NSLog(@"timers started");
    tweetTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 
                                                  target:self 
                                                selector:@selector(nextTweet) 
                                                userInfo:nil 
                                                 repeats:YES];
    
    getNewTweetTimer = [NSTimer scheduledTimerWithTimeInterval:(15*[tweetArray count]) 
                                                        target:self 
                                                      selector:@selector(getNewTweets) 
                                                      userInfo:nil 
                                                       repeats:YES];
    
}



-(void) invalidateTimers {
    [tweetTimer invalidate];
    [getNewTweetTimer invalidate];
}



@end
