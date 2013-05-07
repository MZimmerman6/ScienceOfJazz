//
//  METFlickrSetViewController.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METFlickrSetView.h"
#import "METFlickrPhoto.h"

int const perPage = 32;

@implementation METFlickrSetView

@synthesize photoTable, photoSet, photoArray, custom, linkRequest, linkConnection, photoPage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id) initWithPhotoSet:(METFlickrSet*)flickrSet APIKey:(NSString*)apiKey Frame:(CGRect)frame andDelegate:(id)flickrSetDelegate {
    
    self = [super initWithFrame:frame];
    [self setPhotoSet:flickrSet];
    photoPage = 1;
    photosetAPIKey = apiKey;
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest?format=json&method=flickr.photosets.getPhotos&photoset_id=%@&privacy_filter=1&per_page=%i&page=%i&api_key=%@",[flickrSet setID],perPage,photoPage, apiKey];
    NSURL *linkURL = [NSURL URLWithString:urlString];
    delegate = flickrSetDelegate;
    
    photoData = [[NSMutableData alloc] init];
    
    linkRequest = [[NSURLRequest alloc] initWithURL:linkURL
                                        cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                    timeoutInterval:10.0];
    linkConnection = [[NSURLConnection alloc] initWithRequest:linkRequest delegate:self];
    
    photoTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [photoTable setRowHeight:80];
    [photoTable setDelegate:self];
    [photoTable setDataSource:self];
    [self addSubview:photoTable];
    
    return self;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (connection == linkConnection) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                        message:@"An error was encountered while connecting to Flickr server. Please check internet connection, and try again" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Close" 
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        METFlickrPhoto *tempPhoto = [[METFlickrPhoto alloc] init];
        for (int i = 0;i<[photoArray count]; i++) {
            tempPhoto = [photoArray objectAtIndex:i];
            if (connection == tempPhoto.photoConnection) {
                [tempPhoto setPhotoFailed:YES];
                NSLog(@"failed to load photo");
            } else if (connection == tempPhoto.thumbConnection) {
                [tempPhoto setThumbFailed:YES];
                NSLog(@"failed to load thumbnail");
            }
        }
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == linkConnection) {
        [photoData appendData:data];
    } else {
        METFlickrPhoto *tempPhoto = [[METFlickrPhoto alloc] init];
        for (int i= 0;i<[photoArray count];i++) {
            tempPhoto = [photoArray objectAtIndex:i];
            if (connection == tempPhoto.thumbConnection) {
                [tempPhoto.thumbData appendData:data];
                [photoArray replaceObjectAtIndex:i withObject:tempPhoto];
                break;
            } else if (connection == tempPhoto.photoConnection) {
                [tempPhoto.photoData appendData:data];
                [photoArray replaceObjectAtIndex:i withObject:tempPhoto];
                break;
            }
        }
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == linkConnection) {
        [self parsePhotos];
    } else {
        METFlickrPhoto *tempPhoto = [[METFlickrPhoto alloc] init];
        for (int i = 0;i <[photoArray count];i++) {
            tempPhoto = [photoArray objectAtIndex:i];
            if (connection == tempPhoto.thumbConnection) {
                [tempPhoto setThumbDone:YES];
                tempPhoto.thumbnail = [[UIImage alloc] initWithData:tempPhoto.thumbData];
                [photoArray replaceObjectAtIndex:i withObject:tempPhoto];
                break;
            } else if (connection == tempPhoto.photoConnection) {
                [tempPhoto setPhotoDone:YES];
                tempPhoto.photo = [[UIImage alloc] initWithData:tempPhoto.photoData];
                [photoArray replaceObjectAtIndex:i withObject:tempPhoto];
                break;
            }
        }
        [photoTable reloadData];
        
        if ([self arePhotosLoaded]) {
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = NO;
        }
    }
}


-(BOOL) arePhotosLoaded {
    
    for (int i = 1;i<[photoArray count];i++) {
        if (![[photoArray objectAtIndex:i] thumbDone]) {
            return NO;
        }
    }
    return YES;
}

-(void) parsePhotos {
    
    NSString *photoString = [[NSString alloc] initWithData:photoData encoding:NSUTF8StringEncoding];
    photoString = [photoString stringByReplacingOccurrencesOfString:@"\"ok\"})" withString:@"\"ok\"}"];
    photoString = [photoString stringByReplacingOccurrencesOfString:@"jsonFlickrApi(" withString:@""];
    photoData = (NSMutableData*)[photoString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *photoDictionary = [NSJSONSerialization JSONObjectWithData:photoData 
                                                                    options:NSJSONReadingMutableLeaves 
                                                                      error:nil];
//    NSLog(@"%@",photoDictionary);
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        NSArray *photos = [[photoDictionary objectForKey:@"photoset"] objectForKey:@"photo"];
        METFlickrPhoto *tempPhoto = [[METFlickrPhoto alloc] init];
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        for (int i = 0;i<[photos count];i++) {
            tempPhoto = [[METFlickrPhoto alloc] init];
            tempDict = [photos objectAtIndex:i];
            tempPhoto.title = [tempDict objectForKey:@"title"];
            tempPhoto.server = [tempDict objectForKey:@"server"];
            tempPhoto.photoID = [tempDict objectForKey:@"id"];
            tempPhoto.secret = [tempDict objectForKey:@"secret"];
            tempPhoto.farm = [tempDict objectForKey:@"farm"];
            tempPhoto.isPrimary = [tempDict objectForKey:@"isprimary"];
            tempPhoto.photoData = [[NSMutableData alloc] init];
            tempPhoto.thumbData = [[NSMutableData alloc] init];
            tempPhoto.thumbDone = YES;
            tempPhoto.photoDone = NO;
            tempPhoto.thumbFailed = NO;
            tempPhoto.photoFailed = NO;
            tempPhoto.thumbURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_t.jpg",tempPhoto.farm,tempPhoto.server,tempPhoto.photoID,tempPhoto.secret];
            tempPhoto.photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@.jpg",tempPhoto.farm,tempPhoto.server,tempPhoto.photoID,tempPhoto.secret];
            tempPhoto.thumbURL = [[NSURL alloc] initWithString:tempPhoto.thumbURLString];
            tempPhoto.photoURL = [[NSURL alloc] initWithString:tempPhoto.photoURLString];
            
            tempPhoto.thumbRequest = [[NSURLRequest alloc] initWithURL:tempPhoto.thumbURL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                                       timeoutInterval:20.0];
            tempPhoto.photoRequest = [[NSURLRequest alloc] initWithURL:tempPhoto.photoURL
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                                       timeoutInterval:20.0];
            
            
            [tempArray addObject:tempPhoto];
        }
        if (photoPage == 1) {
            [self setPhotoArray:tempArray];
        } else {
            [photoArray addObjectsFromArray:tempArray];
        }
    }
    [photoTable reloadData];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (photoArray) {
        if (photoSet.numPhotos > [photoArray count]) {
            return ceil([photoArray count]/4.0)+1;
        } else {
            return ceil([photoArray count]/4.0);
        }
    } else {
        return [photoArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //cell.backgroundColor = [UIColor blackColor];
    UIButton *tempButton = [[UIButton alloc] init];
    UIImageView *tempImageView = [[UIImageView alloc] init];
    
    
    if (photoArray) {
        if (indexPath.row+1 > ceil([photoArray count]/4.0)) {
            cell.textLabel.text = @"Load More Photos";
//            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            return cell;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int numColumns = 4;
        int startIndex = indexPath.row*numColumns;
        int endIndex = startIndex +numColumns-1;
        int count = 0;
        METFlickrPhoto *tempPhoto = [[METFlickrPhoto alloc] init];
        for (int i = startIndex;i<=endIndex;i++) {
            if (i<[photoArray count]) {
                tempPhoto = [photoArray objectAtIndex:i];
                if (!tempPhoto.connectionCreated) {
                    NSURLConnection *thumbConnect = [[NSURLConnection alloc] initWithRequest:tempPhoto.thumbRequest delegate:self];
                    [[photoArray objectAtIndex:i] setThumbConnection:thumbConnect];
                    [[photoArray objectAtIndex:i] setConnectionCreated:YES];
                    [[photoArray objectAtIndex:i] setThumbDone:NO];
                    UIApplication* app = [UIApplication sharedApplication];
                    app.networkActivityIndicatorVisible = YES;
                }
                
                tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+count*80, 5, 70, 70)];
                tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
                tempButton.frame = CGRectMake(5+count*80, 5, 70, 70);
                tempButton.tag = i;
                
                [tempButton addTarget:self action:@selector(photoPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                if (tempPhoto.thumbDone) {
                    [tempButton setBackgroundImage:tempPhoto.thumbnail forState:UIControlStateNormal];
                } else {
                    [tempButton setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
                }
                [cell.contentView addSubview:tempButton];
                count++;
            }
        }
    }
    
    //[cell addSubview:tempView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row+1 > ceil([photoArray count]/4.0)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self getMorePictures];
    }
}

-(void) getMorePictures {
    
    photoPage++;
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest?format=json&method=flickr.photosets.getPhotos&photoset_id=%@&privacy_filter=1&per_page=%i&page=%i&api_key=%@",[photoSet setID],perPage,photoPage, photosetAPIKey];
    NSURL *linkURL = [NSURL URLWithString:urlString];
    photoData = [[NSMutableData alloc] init];
    
    linkRequest = [[NSURLRequest alloc] initWithURL:linkURL
                                        cachePolicy:NSURLRequestReloadRevalidatingCacheData 
                                    timeoutInterval:10.0];
    linkConnection = [[NSURLConnection alloc] initWithRequest:linkRequest delegate:self];
}

-(IBAction)photoPressed:(id)sender {
    
//    NSLog(@"photo pressed");
    [delegate didSelectFlickrPhoto:[photoArray objectAtIndex:[sender tag]] fromArray:photoArray andSet:photoSet atIndex:[sender tag]];
    
}

@end
