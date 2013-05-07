//
//  SoundBlob.h
//  SoundField
//
//  Created by Brian Dolhansky on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SoundBlob : UIViewController {
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
