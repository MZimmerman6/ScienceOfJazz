//
//  AudioFunctions.h
//  AudioAnalysis
//
//  Created by Matthew Zimmerman on 6/23/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioFunctions : NSObject

+(float*) addImaginaryPart:(float*)array arraySize:(int)size;

+(float*) hamming:(int)length power:(float)power;


@end
