//
//  TakeOverViewController.h
//  ScienceOfJazz
//
//  Created by Matthew Zimmerman on 4/16/13.
//
//

#import <UIKit/UIKit.h>

@interface TakeOverViewController : UIViewController {
    
    
    float *coordinates;
    float *powerValues;
    float *roomDimensions;
    
}

@property (strong, nonatomic) IBOutlet UIView *colorOverlay;

-(void) removeFromView;

-(void) updateScreenToColor:(UIColor*)color;

@end
