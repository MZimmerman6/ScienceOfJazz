//
//  METFlickrSetView.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METFlickrPhoto.h"
#import "METFlickrSet.h"

@protocol METFlickrSetViewDelegate;

@interface METFlickrSetView : UIView <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *photoTable;
    METFlickrSet *photoSet;
    NSMutableData *photoData;
    NSMutableArray *photoArray;
    UIView *custom;
    NSURLConnection *linkConnection;
    NSURLRequest *linkRequest;
    NSString *photosetAPIKey;
    int photoPage;
    id <METFlickrSetViewDelegate> delegate;
    
}

@property (strong, nonatomic) UITableView *photoTable;
@property (strong, nonatomic) METFlickrSet *photoSet;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) UIView *custom;
@property (strong, nonatomic) NSURLRequest *linkRequest;
@property (strong, nonatomic) NSURLConnection *linkConnection;
@property int photoPage;

-(id) initWithPhotoSet:(METFlickrSet*)flickrSet APIKey:(NSString*)apiKey Frame:(CGRect)frame andDelegate:(id)flickrSetDelegate;

-(void) parsePhotos;

-(IBAction)photoPressed:(id)sender;

-(void) getMorePictures;

-(BOOL) arePhotosLoaded;


@end

@protocol METFlickrSetViewDelegate

@required

-(void) didSelectFlickrPhoto:(METFlickrPhoto*)flickrPhoto fromArray:(NSMutableArray*)photoArray andSet:(METFlickrSet*)flickrSet atIndex:(int)index;

@end