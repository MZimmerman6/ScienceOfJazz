//
//  METFlickrGalleryView.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METFlickrGalleryView.h"

@implementation METFlickrGalleryView

@synthesize currentIndex, currentPhoto, picView, picture, lastButton, nextButton, picArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithPhotoArray:(NSMutableArray*)photoArray atIndex:(int)index withFrame:(CGRect)frame andDelegate:(id)galleryDelegate {
    
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor blackColor]];
    
    delegate = galleryDelegate;
    picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    [picView setContentMode:UIViewContentModeScaleAspectFit];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [picView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    currentIndex = index;
    picArray = [[NSMutableArray alloc] init];
    [self setPicArray:photoArray];
    [self addSubview:picView];
    
    lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lastButton.frame = CGRectMake(285, 180, 30, 30);
    [lastButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [lastButton addTarget:self action:@selector(goToLastPicture) forControlEvents:UIControlEventTouchUpInside];
    [lastButton setBackgroundImage:[UIImage imageNamed:@"rightarrow.png"] forState:UIControlStateNormal];
    
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(15, 180, 30, 30);
    [nextButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [nextButton addTarget:self action:@selector(goToNextPicture) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"leftarrow.png"] forState:UIControlStateNormal];
    
    connectionCount = 0;
    
    [self addSubview:lastButton];
    [self addSubview:nextButton];
    [self showPhotoAtIndex:currentIndex];
    return self;
}

-(void) showPhotoAtIndex:(int)index {
    
    METFlickrPhoto *tempPhoto = [picArray objectAtIndex:currentIndex];
    if ([tempPhoto photoDone]) {
        picView.image = [tempPhoto photo];
    } else {
        picView.image = [tempPhoto thumbnail];
        [self getFullPicture:tempPhoto];
        connectionCount++;
    }
}

-(void) getFullPicture:(METFlickrPhoto*)pic {
    if (![pic photoConnection]) {
        [pic setPhotoDone:NO];
        pic.photoData = [[NSMutableData alloc] init];
        [pic setPhotoConnection:[[NSURLConnection alloc] initWithRequest:[pic photoRequest] delegate:self]];
    }
}


-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    for (int i = 0;i<[picArray count];i++) {
        if (connection == [[picArray objectAtIndex:i] photoConnection]) {
            [[picArray objectAtIndex:i] setPhotoDone:NO];
            [[picArray objectAtIndex:i] setPhotoConnection:nil];
            connectionCount--;
            break;
        }
    }
    [self updatePictureView];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    for (int i = 0;i<[picArray count];i++) {
        if (connection == [[picArray objectAtIndex:i] photoConnection]) {
            [[[picArray objectAtIndex:i] photoData] appendData:data];
            break;
        }
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    for (int i = 0;i<[picArray count];i++) {
        if (connection == [[picArray objectAtIndex:i] photoConnection]) {
            [[picArray objectAtIndex:i] setPhotoDone:YES];
            [[picArray objectAtIndex:i] setPhoto:[UIImage imageWithData:[[picArray objectAtIndex:i] photoData]]];
            connectionCount--;
            break;
        }
    }
    [self updatePictureView];
}

-(void) goToLastPicture {
    
    currentIndex--;
    if (currentIndex<0) {
        currentIndex = [picArray count]-1;
    }
    [self showPhotoAtIndex:currentIndex];
    
}

-(void) goToNextPicture {
    currentIndex = (currentIndex+1)%[picArray count];
    [self showPhotoAtIndex:currentIndex];
}

-(void) updatePictureView {
    
    if ([[picArray objectAtIndex:currentIndex] photoDone]) {
        picView.image = [[picArray objectAtIndex:currentIndex] photo];
    }
    
    if (connectionCount == 0){
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    
    [picView setNeedsDisplay];
}

@end
