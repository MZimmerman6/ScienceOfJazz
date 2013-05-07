//
//  METFlickrGalleryView.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METFlickrPhoto.h"

@protocol METFlickrGalleryViewDelegate;

@interface METFlickrGalleryView : UIView <NSURLConnectionDataDelegate,NSURLConnectionDelegate> {
    
    NSMutableArray *picArray;
    UIImageView *picView;
    int currentIndex;
    UIImage *picture;
    BOOL isLoading;
    UIButton *lastButton;
    UIButton *nextButton;
    METFlickrPhoto *currentPhoto;
    id <METFlickrGalleryViewDelegate> delegate;
    int connectionCount;
    
}

@property int currentIndex;
@property (strong, nonatomic) NSMutableArray *picArray;
@property (strong, nonatomic) UIImageView *picView;
@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) UIButton *lastButton;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) METFlickrPhoto *currentPhoto;


-(id) initWithPhotoArray:(NSMutableArray*)photoArray atIndex:(int)index withFrame:(CGRect)frame andDelegate:(id)galleryDelegate;

-(void) getFullPicture:(METFlickrPhoto*)pic;

-(void) goToNextPicture;

-(void) goToLastPicture;

-(void) showPhotoAtIndex:(int)index;

-(void) updatePictureView;

@end

@protocol METFlickrGalleryViewDelegate

@optional

-(void) didGoToNextPhoto:(METFlickrPhoto*)flickrPhoto atIndex:(int)index;

@end
