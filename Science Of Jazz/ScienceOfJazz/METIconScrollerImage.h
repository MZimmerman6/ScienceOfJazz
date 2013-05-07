//
//  METIconScrollerImage.h
//  PhilaSciFest2012
//
//  Created by Matthew Zimmerman on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface METIconScrollerImage : UIImageView {
    
    UIViewController *iconController;
    NSString *iconLabel;
    
}

@property (strong, nonatomic) UIViewController *iconController;
@property (strong, nonatomic) NSString *iconLabel;

-(id) initWithImage:(UIImage*)image label:(NSString*)label andViewController:(UIViewController*)viewController;

@end
