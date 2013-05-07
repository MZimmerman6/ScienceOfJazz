//
//  METIconScroller.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import "METIconScroller.h"

@implementation METIconScroller

@synthesize iconArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithIcons:(NSMutableArray*)icons andFrame:(CGRect)frame andDelegate:(id)iconsDelegate atIndex:(int)index {
    
    NSLog(@"setting up scroller");
    self = [super initWithFrame:frame];
    
    leftHiddenFrame = CGRectMake(-85, 186, 50, 50);
    leftFrame = CGRectMake(20, 186, 50, 50);
    centerFrame = CGRectMake(100, 150, 120, 120);
    rightFrame = CGRectMake(250, 186, 50, 50);
    rightHiddenFrame = CGRectMake(360, 186, 50, 50);
    
    delegate = iconsDelegate; 
    
    iconIndex = index;
    iconArray = [[NSMutableArray alloc] init];
    if (self) {
        [self setIconArray:icons];
        [self alignToIndex:iconIndex];
        for (int i = 0;i<[iconArray count];i++) {
            [self addSubview:[iconArray objectAtIndex:i]];
        }
    } 
    
    UIGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
	[self addGestureRecognizer:recognizer];
    tapRecognizer = (UITapGestureRecognizer *)recognizer;
    recognizer.delegate = self;
    return self;
}



-(void) alignToIndex:(int)index {
    
    
    for (int i = 0;i<[iconArray count];i++) {
        if (i<=(index-2)) {
            [[iconArray objectAtIndex:i] setFrame:leftHiddenFrame];
        } else if (i==(index-1)) {
            [[iconArray objectAtIndex:i] setFrame:leftFrame];
        } else if (i==index) {
            [[iconArray objectAtIndex:i] setFrame:centerFrame];
        } else if (i==(index+1)) {
            [[iconArray objectAtIndex:i] setFrame:rightFrame];
        } else if (i>=(index+2)) {
            [[iconArray objectAtIndex:i] setFrame:rightHiddenFrame];
        }
    }
}

-(void) moveIconsLeft {
    
    if (iconIndex<([iconArray count]-1)) {
        [UIView beginAnimations:@"MoveAndStretch" context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationBeginsFromCurrentState:YES];
        iconIndex++;
        [self alignToIndex:iconIndex];
        [UIView commitAnimations];
        
        if ([delegate respondsToSelector:@selector(movedIconsLeftToIndex:)]) {
            [delegate movedIconsLeftToIndex:iconIndex];
        }
        if ([delegate respondsToSelector:@selector(movedToIndex:fromIndex:)]) {
            [delegate movedToIndex:iconIndex fromIndex:(iconIndex-1)];
        }
        
    }
    
}

-(void) moveIconsRight {
    
    if (iconIndex>0) {
        [UIView beginAnimations:@"MoveAndStretch" context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationBeginsFromCurrentState:YES];
        iconIndex--;
        [self alignToIndex:iconIndex];
        [UIView commitAnimations];
        
        if ([delegate respondsToSelector:@selector(movedIconsRightToIndex:)]) {
            [delegate movedIconsRightToIndex:iconIndex];
        }
        if ([delegate respondsToSelector:@selector(movedToIndex:fromIndex:)]) {
            [delegate movedToIndex:iconIndex fromIndex:(iconIndex+1)];
        }
    }
    
}

-(float) shiftOfNew:(CGPoint)newLocation fromOld:(CGPoint)oldLocation {
    
    float xDif = newLocation.x - oldLocation.x;
    return xDif;
}



-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    initialTouchLocation = touchLocation;
    newTouch = true;
    
    if ([delegate respondsToSelector:@selector(touchDetectedAtPoint:)]) {
        [delegate touchDetectedAtPoint:touchLocation];
    }
    
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    float initialXDif = 0;
    float movedXDif = 0;
    if (newTouch) {
        initialXDif = [self shiftOfNew:touchLocation fromOld:initialTouchLocation];
        movedXDif = initialXDif;
        movedLocation = touchLocation;
        newTouch = false;
    } else {
        movedXDif = [self shiftOfNew:touchLocation fromOld:movedLocation];
        movedLocation = touchLocation;
    }
    
    float percentMoved = movedXDif/320.0;
    float fixedXdif = 115.0*percentMoved;
    float yChange = percentMoved*(centerFrame.size.height-leftFrame.size.height)/2;
    
    [UIView beginAnimations:@"MoveAndStretch" context:nil];
    [UIView setAnimationDuration:1/60];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // Looking to see if there should be a left hidden frame, if so adjusting it with adjusted touch location    
    if ((iconIndex-2)>=0) {
        CGRect hlframe = [[iconArray objectAtIndex:(iconIndex-2)] frame];
        hlframe = CGRectMake(hlframe.origin.x+fixedXdif, hlframe.origin.y, hlframe.size.width, hlframe.size.height);
        [[iconArray objectAtIndex:(iconIndex-2)] setFrame:hlframe];
    }
    
    // Looking to see if there should be a left frame, if so adjusting it with adjusted touch location   
    if ((iconIndex-1)>=0) {
        CGRect lframe = [[iconArray objectAtIndex:(iconIndex-1)] frame];
        if (fixedXdif>=0) {
            if (lframe.origin.x <=20) {
                lframe = CGRectMake(lframe.origin.x+fixedXdif, lframe.origin.y, lframe.size.width, lframe.size.height);
            } else {
                lframe = CGRectMake(lframe.origin.x+fixedXdif-fabsf(yChange), lframe.origin.y-fabsf(yChange), lframe.size.width+fabsf(2*yChange), lframe.size.height+fabsf(2*yChange));
            }
        } else {
            if (lframe.origin.x <=20) {
                lframe = CGRectMake(lframe.origin.x+fixedXdif, lframe.origin.y, lframe.size.width, lframe.size.height);
            } else {
                lframe = CGRectMake(lframe.origin.x+fixedXdif+fabsf(yChange), lframe.origin.y+fabsf(yChange), lframe.size.width-fabsf(2*yChange), lframe.size.height-fabsf(2*yChange));
            }
        }
        [[iconArray objectAtIndex:(iconIndex-1) ] setFrame:lframe];
    }
    
    // Adjusting center frame with adjusted touch location. 
    CGRect cframe = [[iconArray objectAtIndex:iconIndex] frame];
    if (fixedXdif>=0) {
        if (cframe.origin.x<=100) {
            cframe = CGRectMake(cframe.origin.x+fixedXdif-yChange, cframe.origin.y-fabsf(yChange), cframe.size.width+fabsf(2*yChange), cframe.size.height+fabs(2*yChange));
        } else {
            cframe = CGRectMake(cframe.origin.x+fixedXdif+fabsf(yChange), cframe.origin.y+fabsf(yChange), cframe.size.width-fabsf(2*yChange), cframe.size.height-fabs(2*yChange));
        }
    } else {
        if (cframe.origin.x <=100) {
            cframe = CGRectMake(cframe.origin.x+fixedXdif-yChange, cframe.origin.y+fabsf(yChange), cframe.size.width-fabsf(2*yChange), cframe.size.height-fabsf(2*yChange));
        } else {
            cframe = CGRectMake(cframe.origin.x+fixedXdif+yChange, cframe.origin.y-fabsf(yChange), cframe.size.width+fabsf(2*yChange), cframe.size.height+fabsf(2*yChange));
        }
    }
    [[iconArray objectAtIndex:iconIndex] setFrame:cframe];
    
    // Looking to see if there should be a right frame, if so adjusting it with adjusted touch location 
    if ((iconIndex+1)<=([iconArray count]-1)) {
        CGRect rframe = [[iconArray objectAtIndex:(iconIndex+1)] frame];
        if (fixedXdif>=0) {
            if (rframe.origin.x >=250) {
                rframe = CGRectMake(rframe.origin.x+fixedXdif, rframe.origin.y, rframe.size.width, rframe.size.height);
            } else {
                rframe = CGRectMake(rframe.origin.x+fixedXdif+yChange, rframe.origin.y+fabsf(yChange), rframe.size.width-fabsf(2*yChange), rframe.size.height-fabsf(2*yChange));
            }
        } else {
            if (rframe.origin.x >=250) {
                rframe = CGRectMake(rframe.origin.x+fixedXdif, rframe.origin.y, rframe.size.width, rframe.size.height);
            } else {
                rframe = CGRectMake(rframe.origin.x+fixedXdif+yChange, rframe.origin.y-fabsf(yChange), rframe.size.width+fabsf(2*yChange), rframe.size.height+fabsf(2*yChange));
            }
        }
        [[iconArray objectAtIndex:(iconIndex+1)] setFrame:rframe];
    }
    
    // Looking to see if there should be a right hidden frame, if so adjusting it with adjusted touch location 
    if ((iconIndex+2)<=([iconArray count]-1)) {
        CGRect hrframe = [[iconArray objectAtIndex:(iconIndex+2)] frame];
        hrframe = CGRectMake(hrframe.origin.x+fixedXdif, hrframe.origin.y, hrframe.size.width, hrframe.size.height);
        [[iconArray objectAtIndex:(iconIndex+2)] setFrame:hrframe];
    }
    
    [UIView commitAnimations];  
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    float xDif = [self shiftOfNew:touchLocation fromOld:initialTouchLocation];
    if (xDif > 320.0/3.0 && iconIndex != 0) {
        [self moveIconsRight];
    } else if (xDif < -320.0/3.0 && iconIndex != ([iconArray count]-1)) {
        [self moveIconsLeft];
    } else {
        [UIView beginAnimations:@"MoveAndStretch" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self alignToIndex:iconIndex];       
        [UIView commitAnimations];
    }
    
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self];
    if (location.x >= 100 && location.x<=220 && location.y >= 161 && location.y <= 281) {
        [delegate didSelectIconAtIndex:iconIndex];
    } else if (location.x >=10 && location.x<=80 && location.y >= 200 && location.y <=260) {
        [self moveIconsRight];
    } else if (location.x >=240 && location.x<=300 && location.y >= 200 && location.y <=260) {
        [self moveIconsLeft];
    }
}

@end
