//
//  METYoutubeView.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METYoutubeView.h"


@implementation METYoutubeView

@synthesize videoArray, videoTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithUserVideos:(NSString *)userName andFrame:(CGRect)frame andDelegate:(id)ytDelegate {
    
    self  = [super initWithFrame:frame];
    userChosen = YES;
    playlistChosen = NO;
    delegate = ytDelegate;
    videoTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [videoTable setSectionHeaderHeight:1];
    [videoTable setRowHeight:92];
    [videoTable setDelegate:self];
    [videoTable setDataSource:self];
    [self addSubview:videoTable];
    pageData = [[NSMutableData alloc] init];
    playlistURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&author=%@",userName]];
    
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    NSURLRequest *linkRequest = [[NSURLRequest alloc] initWithURL:playlistURL
                                                      cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                                  timeoutInterval:10.0];
    pageConnection = [[NSURLConnection alloc] initWithRequest:linkRequest delegate:self];
    
    return self;
    
}

-(id) initWithUserPlaylist:(NSString *)playListCode andFrame:(CGRect)frame andDelegate:(id)ytDelegate {
    
    
    self = [super initWithFrame:frame];
    playlistChosen = YES;
    userChosen = NO;
    delegate = ytDelegate;
    [self setFrame:frame];
    videoTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [videoTable setSectionHeaderHeight:1];
    [videoTable setRowHeight:92];
    [videoTable setDelegate:self];
    [videoTable setDataSource:self];
    [self addSubview:videoTable];
    
    pageData = [[NSMutableData alloc] init];
    playlistURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/%@?v=2&alt=json",playListCode]];
    
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    NSURLRequest *linkRequest = [[NSURLRequest alloc] initWithURL:playlistURL
                                                      cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                                  timeoutInterval:10.0];
    pageConnection = [[NSURLConnection alloc] initWithRequest:linkRequest delegate:self];
    return self;
    
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == pageConnection) {
        [pageData appendData:data];
    } else {
        for (int i = 0; i<[videoArray count];i++) {
            if (connection==[[videoArray objectAtIndex:i] thumbConnection]){
                [[[videoArray objectAtIndex:i] thumbData] appendData:data];
                //                NSLog(@"got pic data");
                break;
            }
        }
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == pageConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Youtube Error" message:@"Unable to reach Youtube servers. Please try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == pageConnection) {
        if (userChosen) {
            [self processUserVideoData];
        } else if (playlistChosen) {
            [self processPlaylistVideoData];
        }
    } else {
        for (int i = 0; i<[videoArray count];i++) {
            if (connection==[[videoArray objectAtIndex:i] thumbConnection]){
                [[videoArray objectAtIndex:i] processPicture];
                [videoTable reloadData];
                //                NSLog(@"got picture");
                break;
            }
        }
    }
    if ([self doneGettingPictures]) {
        if ([delegate respondsToSelector:@selector(allVideoDataLoaded)]){
            [delegate allVideoDataLoaded];
        }
    }
    
}


-(BOOL) doneGettingPictures {
    
    for (int i = 0;i<[videoArray count];i++) {
        if (![[videoArray objectAtIndex:i] connectionDone]) {
            return NO;
        }
    }
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    return YES;
    
}

-(void) processPlaylistVideoData {
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSDictionary *playlist = [NSJSONSerialization JSONObjectWithData:pageData options:NSJSONReadingMutableContainers error:nil];
    NSArray *entries = [[playlist objectForKey:@"feed"] objectForKey:@"entry"];
    METYoutubeVideo *tempVideo;
    @autoreleasepool {
        for (int i = 0;i<[entries count]; i++) {
            @try {
                tempVideo = [[METYoutubeVideo alloc] init];
                NSDictionary *video = [entries objectAtIndex:i];
                //            NSLog(@"%@",video);
                NSString *linkString = [[[video objectForKey:@"link"] objectAtIndex:0] objectForKey:@"href"];
                linkString = [linkString stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata" withString:@""];
                linkString = [linkString stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
                
                NSString *titleString = [[video objectForKey:@"title"] objectForKey:@"$t"];
                
                NSString *thumbnailURLString = [[[[video objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:0] objectForKey:@"url"];
                NSString *userString = [[[[video objectForKey:@"media$group"] objectForKey:@"media$credit"] objectAtIndex:0] objectForKey:@"$t"];
                
                NSString *timeString = [[[[video objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:0] objectForKey:@"time"];
                
                NSString *descriptionString = [[[video objectForKey:@"media$group"] objectForKey:@"media$description"] objectForKey:@"$t"];
                
                int viewcount = [[[video objectForKey:@"yt$statistics"] objectForKey:@"viewCount"] intValue];
                
                float averageRating = [[[video objectForKey:@"gd$rating"] objectForKey:@"average"] floatValue];
                float percent = (averageRating/5.0)*100.0;
                
                
                NSArray *timeSeparate = [timeString componentsSeparatedByString:@":"];
                
                int hours = [[timeSeparate objectAtIndex:0] intValue];
                int minutes = [[timeSeparate objectAtIndex:1] intValue];
                int seconds = [[timeSeparate objectAtIndex:2] intValue];
                int totalSeconds = hours*3600 + minutes *60+seconds;
                
                if (hours ==0) {
                    [tempVideo setTimeString:[NSString stringWithFormat:@"%i:%i",minutes,seconds]];
                } else {
                    [tempVideo setTimeString:[NSString stringWithFormat:@"%i:%i:%i",hours,minutes,seconds]];
                }
                
                [tempVideo setRating:(int)percent];
                [tempVideo setNumViews:viewcount];
                [tempVideo setTitle:titleString];
                [tempVideo setLength:totalSeconds];
                [tempVideo setVideoURL:[[NSURL alloc] initWithString:linkString]];
                [tempVideo setThumbnailURL:[[NSURL alloc] initWithString:thumbnailURLString]];
                [tempVideo setAuthor:userString];
                [tempVideo setDescription:descriptionString];
                [tempVideo setThumbRequest:[[NSURLRequest alloc] initWithURL:[tempVideo thumbnailURL] 
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                             timeoutInterval:10.0]];
                [tempVideo setConnectionStarted:NO];
                [tempVideo setConnectionDone:YES];
                [tempVideo setPicture:[UIImage imageNamed:@"camera.png"]];
                [tempVideo setGotPicture:NO];
                [tempArray addObject:tempVideo];
            } @catch (NSException *nse) {}
            
        }
    }
    [self setVideoArray:tempArray];
    [self performSelectorOnMainThread:@selector(doneGettingYoutubeVideos) withObject:nil waitUntilDone:NO];
}

-(void) processUserVideoData {
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    @autoreleasepool {
        
        NSDictionary *playlist = [NSJSONSerialization JSONObjectWithData:pageData options:NSJSONReadingMutableContainers error:nil];
        NSArray *entries = [[playlist objectForKey:@"data"] objectForKey:@"items"];
        METYoutubeVideo *tempVideo;
        
        for (int i = 0;i<[entries count]; i++) {
            @try {
                tempVideo = [[METYoutubeVideo alloc] init];
                
                NSDictionary *video = [entries objectAtIndex:i];
                NSString *linkString = [[video objectForKey:@"player"] objectForKey:@"default"];
                NSString *titleString = [video objectForKey:@"title"];
                NSString *thumbnailURLString = [[video objectForKey:@"thumbnail"] objectForKey:@"sqDefault"];
                NSString *descriptionString = [video objectForKey:@"description"];
                NSString *userString = [video objectForKey:@"uploader"];
                
                int viewcount = [[video objectForKey:@"viewCount"] intValue];
                
                float averageRating = [[video objectForKey:@"rating"] floatValue];
                float percent = (averageRating/5.0)*100.0;
                
                NSString *durationString = [video objectForKey:@"duration"];
                double totalSeconds = [durationString doubleValue];
                
                int hours = (int)floor(totalSeconds/3600);
                int minutes = (int)floor((totalSeconds-hours*3600.0)/60.0);
                int seconds = (int)floor((totalSeconds-hours*3600.0-minutes*60));
                NSString *secondString = @"";
                if (seconds <10)
                {
                    secondString = [NSString stringWithFormat:@"0%i",seconds];
                } else {
                    secondString = [NSString stringWithFormat:@"%i",seconds];
                }
                
                if (hours ==0) {
                    [tempVideo setTimeString:[NSString stringWithFormat:@"%i:%@",minutes,secondString]];
                } else {
                    [tempVideo setTimeString:[NSString stringWithFormat:@"%i:%i:%@",hours,minutes,secondString]];
                }
                
                [tempVideo setRating:(int)percent];
                [tempVideo setNumViews:viewcount];
                [tempVideo setTitle:titleString];
                [tempVideo setLength:totalSeconds];
                [tempVideo setVideoURL:[[NSURL alloc] initWithString:linkString]];
                [tempVideo setThumbnailURL:[[NSURL alloc] initWithString:thumbnailURLString]];
                [tempVideo setAuthor:userString];
                [tempVideo setDescription:descriptionString];
                [tempVideo setPicture:[UIImage imageNamed:@"camera.png"]];
                [tempVideo setGotPicture:NO];
                [tempVideo setThumbRequest:[[NSURLRequest alloc] initWithURL:[tempVideo thumbnailURL] 
                                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                             timeoutInterval:10.0]];
                [tempVideo setConnectionStarted:NO];
                [tempVideo setConnectionDone:YES];
                [tempArray addObject:tempVideo];
            } @catch (NSException *nse) {}
            
        }
    }
    [self setVideoArray:tempArray];
    [self performSelectorOnMainThread:@selector(doneGettingYoutubeVideos) withObject:nil waitUntilDone:NO];
}

-(void) doneGettingYoutubeVideos {
    
    [videoTable reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [videoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    
    
	METYoutubeVideo *video = [videoArray objectAtIndex:indexPath.row];
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, videoTable.rowHeight)];
    customView.backgroundColor = [UIColor clearColor];
    
    
    if (![video gotPicture] && ![video connectionStarted]) {
        [video setThumbConnection:[[NSURLConnection alloc] initWithRequest:[video thumbRequest] delegate:self]];
        [video setConnectionStarted:YES];
        [video setConnectionDone:NO];
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
    }
    UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (videoTable.rowHeight)*4.0/3.0, videoTable.rowHeight)];
    thumbnail.image = video.picture;
    thumbnail.userInteractionEnabled = NO;
    
    UITextView *titleText = [[UITextView alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width, 0, 320-(thumbnail.frame.size.width)-10, 40)];
    titleText.text = video.title;
    titleText.scrollEnabled = NO;
    titleText.editable = NO;
    titleText.font = [UIFont fontWithName:@"CalvertMTStd-Bold" size:18];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.userInteractionEnabled = NO;
    
    UILabel *lengthLab = [[UILabel alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width +6, thumbnail.frame.size.height-20, 40, 16)];
    lengthLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    lengthLab.text = video.timeString;
    lengthLab.userInteractionEnabled = NO;
    lengthLab.backgroundColor = [UIColor clearColor];
    
    UILabel *authorLab = [[UILabel alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width +45, thumbnail.frame.size.height-20, 200, 16)];
    authorLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    authorLab.text = video.author;
    authorLab.backgroundColor = [UIColor clearColor];
    
    UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width +5, 44, 21, 21)];
    thumb.backgroundColor = [UIColor clearColor];
    UILabel *percentLab = [[UILabel alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width + 30, 51, 35, 18)];
    percentLab.backgroundColor = [UIColor clearColor];
    percentLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    
    if (video.rating > 50) {
        thumb.image = [UIImage imageNamed:@"thumbup.png"];
        percentLab.textColor = [UIColor colorWithRed:0.3294 green:0.6196 blue:0.3294 alpha:1];
    } else {
        thumb.image = [UIImage imageNamed:@"thumbdown.png"];
        percentLab.textColor = [UIColor redColor];
    }
    percentLab.text = [NSString stringWithFormat:@"%i%%",video.rating];
    
    UILabel *viewsLab = [[UILabel alloc] initWithFrame:CGRectMake(thumbnail.frame.size.width + 70, 52, 150, 17)];
    viewsLab.text = [NSString stringWithFormat:@"%i views",video.numViews];
    viewsLab.font = [UIFont fontWithName:@"Helvetica" size:11];
    viewsLab.backgroundColor = [UIColor clearColor];
    
    
    [customView addSubview:viewsLab];
    [customView addSubview:thumb];
    [customView addSubview:percentLab];
    [customView addSubview: thumbnail];
    [customView addSubview:titleText];
    [customView addSubview:lengthLab];
    [customView addSubview:authorLab];
    
    [cell addSubview:customView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [delegate didSelectVideo:[videoArray objectAtIndex:indexPath.row] atIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
