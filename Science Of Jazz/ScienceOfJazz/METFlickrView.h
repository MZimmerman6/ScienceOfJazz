//
//  METFlickrViewer.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METFlickrSet.h"

@protocol METFlickrViewDelegate;

@interface METFlickrView : UIView <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    NSURL *flickrURL;
    NSURLRequest *flickrRequest;
    NSURLConnection *flickrConnection;
    NSMutableArray *flickrSetArray;
    NSMutableData *flickrData;
    
    UITableView *flickrSetTable;
    
    id <METFlickrViewDelegate> delegate;
    
}

@property (strong, nonatomic) UITableView *flickrSetTable;
@property (strong, nonatomic) NSMutableArray *flickrSetArray;

-(id) initWithUserID:(NSString*)userID APIKey:(NSString*)apiKey Frame:(CGRect)frame andDelegate:(id)flickrDelegate;

-(void) processFlickrResults;

-(BOOL) arePicturesLoaded;


@end


@protocol METFlickrViewDelegate <NSObject>

@required

-(void) didSelectPhotoSet:(METFlickrSet*)flickrSet atIndex:(int)index; 

@end