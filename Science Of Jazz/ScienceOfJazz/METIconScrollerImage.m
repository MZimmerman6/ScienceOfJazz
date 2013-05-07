//
//  METIconScrollerImage.m
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "METIconScrollerImage.h"

@implementation METIconScrollerImage

@synthesize iconLabel, iconController;



-(id) initWithImage:(UIImage *)image label:(NSString *)label andViewController:(UIViewController *)viewController {
    
    self = [super initWithImage:image];
    [self setIconLabel:label];
    [self setIconController:viewController];
    return self;
    
}

@end
