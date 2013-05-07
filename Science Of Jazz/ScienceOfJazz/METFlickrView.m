//
//  METFlickrViewer.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METFlickrView.h"

@implementation METFlickrView

@synthesize flickrSetArray, flickrSetTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithUserID:(NSString*)userID APIKey:(NSString*)apiKey Frame:(CGRect)frame andDelegate:(id)flickrDelegate {
    
    self = [super initWithFrame:frame];
    
    delegate = flickrDelegate;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    flickrSetTable  = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [flickrSetTable setRowHeight:60];
    [flickrSetTable setDelegate:self];
    [flickrSetTable setDataSource:self];
    [self addSubview:flickrSetTable];
    flickrData = [[NSMutableData alloc] init];
    flickrURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest?method=flickr.photosets.getList&user_id=%@&format=json&api_key=%@",userID, apiKey]];
    flickrRequest = [[NSURLRequest alloc] initWithURL:flickrURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    flickrConnection = [[NSURLConnection alloc] initWithRequest:flickrRequest delegate:self];
    return self;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == flickrConnection) {
        [flickrData appendData:data];
    } else {
        for (int i = 0;i<[flickrSetArray count];i++) {
            if (connection == [[flickrSetArray objectAtIndex:i] thumbConnection]) {
                [[[flickrSetArray objectAtIndex:i] thumbData] appendData:data];
                break;
            }
        }
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (connection == flickrConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flickr Error" message:@"Unable to reach Flickr servers. Please try again later." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == flickrConnection) {
        NSString *temp = [[NSString alloc] initWithData:flickrData encoding:NSUTF8StringEncoding];
        temp = [temp stringByReplacingOccurrencesOfString:@"\"ok\"})" withString:@"\"ok\"}"];
        temp = [temp stringByReplacingOccurrencesOfString:@"jsonFlickrApi(" withString:@""];
        flickrData = (NSMutableData*)[temp dataUsingEncoding:NSUTF8StringEncoding];
        [self processFlickrResults];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    } else {
        for (int i = 0;i<[flickrSetArray count];i++) {
            if (connection == [[flickrSetArray objectAtIndex:i] thumbConnection]) {
                [[flickrSetArray objectAtIndex:i] processThumbImage];
                [flickrSetTable reloadData];
                if ([self arePicturesLoaded]) {
                    UIApplication* app = [UIApplication sharedApplication];
                    app.networkActivityIndicatorVisible = NO;
                }
                break;
            }
        }
    }
}

-(void) processFlickrResults {
    
    NSDictionary *flickrDictionary = [NSJSONSerialization JSONObjectWithData:flickrData 
                                                                     options:NSJSONReadingMutableLeaves 
                                                                       error:nil];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    @autoreleasepool {
        NSArray *photosets = [[flickrDictionary objectForKey:@"photosets"] objectForKey:@"photoset"];
        METFlickrSet *tempFlickrSet = [[METFlickrSet alloc] init];
        NSDictionary *tempDictionary = [[NSDictionary alloc] init];
        for (int i =0;i<[photosets count];i++) {
            tempFlickrSet = [[METFlickrSet alloc] init];
            tempDictionary = [photosets objectAtIndex:i];
            tempFlickrSet.title = [[tempDictionary objectForKey:@"title"] objectForKey:@"_content"];
            tempFlickrSet.server = [tempDictionary objectForKey:@"server"];
            tempFlickrSet.secret = [tempDictionary objectForKey:@"secret"];
            tempFlickrSet.farm = [tempDictionary objectForKey:@"farm"];
            tempFlickrSet.primary = [tempDictionary objectForKey:@"primary"];
            tempFlickrSet.description = [[tempDictionary objectForKey:@"description"] objectForKey:@"_content"];
            tempFlickrSet.setID = [tempDictionary objectForKey:@"id"]; 
            tempFlickrSet.numPhotos = [[tempDictionary objectForKey:@"photos"] intValue];
            tempFlickrSet.thumbData = [[NSMutableData alloc] init];
            tempFlickrSet.urlString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",tempFlickrSet.farm, tempFlickrSet.server,tempFlickrSet.primary, tempFlickrSet.secret];
            tempFlickrSet.thumbURL = [NSURL URLWithString:tempFlickrSet.urlString];
            [tempFlickrSet setPhotoLoaded:NO];
            [tempFlickrSet setConnectCreated:NO];
            tempFlickrSet.thumbRequest = [[NSURLRequest alloc] initWithURL:tempFlickrSet.thumbURL
                                                               cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                                           timeoutInterval:10.0];
            tempFlickrSet.thumbnail = [UIImage imageNamed:@"camera.png"];
            [tempFlickrSet setPictureDone:YES];
            [tempArray addObject:tempFlickrSet];
        }
        [self setFlickrSetArray:tempArray];
    }
    
    [flickrSetTable reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [flickrSetArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    
    METFlickrSet *tempSet = [flickrSetArray objectAtIndex:indexPath.row];
    
    if (!tempSet.connectCreated) {
        NSURLConnection *thumbConnect = [[NSURLConnection alloc] initWithRequest:tempSet.thumbRequest delegate:self];
        [tempSet setThumbConnection:thumbConnect];
        [tempSet setConnectCreated:YES];
        tempSet.thumbData = [[NSMutableData alloc] init];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        [tempSet setPictureDone:NO];
    }
    cell.imageView.image = [tempSet thumbnail];
    cell.textLabel.text = [tempSet title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"selected flickr set");
    [delegate didSelectPhotoSet:[flickrSetArray objectAtIndex:indexPath.row] atIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL) arePicturesLoaded {
    
    for (int i = 1;i<[flickrSetArray count];i++) {
        if (![[flickrSetArray objectAtIndex:i] pictureDone]) {
            return NO;
        }
    }
    return YES;
}


@end
