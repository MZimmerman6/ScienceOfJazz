//
//  FloatFunctions.h
//  ScienceOfJazz
//
//  Created by ExCITe on 4/12/13.
//
//

#import <Foundation/Foundation.h>

@interface FloatFunctions : NSObject


+(float) max:(float*)array start:(int)start end:(int)end;

+(float) min:(float*)array start:(int)start end:(int)end;

+(float*) linspace:(float)start end:(float)end numElements:(int)numElements;

@end
