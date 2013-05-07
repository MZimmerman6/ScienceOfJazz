//
//  METIconScroller.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "METIconScrollerImage.h"

@protocol METIconScrollerDelegate;

@interface METIconScroller : UIView <UIGestureRecognizerDelegate> {
    
    UITapGestureRecognizer *tapRecognizer;
    BOOL first;
    CGPoint initialTouchLocation;
    CGPoint movedLocation;
    BOOL newTouch;
    
    NSMutableArray *iconArray;
    int iconIndex;
    CGRect centerFrame;
    CGRect leftFrame;
    CGRect rightFrame;
    CGRect leftHiddenFrame;
    CGRect rightHiddenFrame;
    id <METIconScrollerDelegate> delegate;
    
}

@property (strong, nonatomic) NSMutableArray *iconArray;

-(void) moveIconsLeft;

-(void) moveIconsRight;

-(void) alignToIndex:(int)index;

-(void)handleTapFrom:(UITapGestureRecognizer *)recognizer;

-(float) shiftOfNew:(CGPoint)newLocation fromOld:(CGPoint)oldLocation;

-(id) initWithIcons:(NSMutableArray*)icons andFrame:(CGRect)frame andDelegate:(id)iconsDelegate atIndex:(int)index;


@end

@protocol METIconScrollerDelegate <NSObject>

-(void) didSelectIconAtIndex:(int)index;

@optional

-(void) movedToIndex:(int)newIndex fromIndex:(int)oldIndex;

-(void) movedIconsLeftToIndex:(int)index;

-(void) movedIconsRightToIndex:(int)index;

-(void) touchDetectedAtPoint:(CGPoint)point;

@end
