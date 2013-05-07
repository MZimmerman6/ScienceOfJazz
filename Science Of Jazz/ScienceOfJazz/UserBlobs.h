//
//  UserBlobs.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UserBlobs : UIViewController {
    UIImageView* blobView;
    CGFloat x, y;
    double intensity;
}

- (id)initWithX:(CGFloat)newX y:(CGFloat)newY;
- (void)changeIntensity:(CGFloat)newIntensity;
- (int)getX;
- (int)getY;
- (double)getIntensity;

@end