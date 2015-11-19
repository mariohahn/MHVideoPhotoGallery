//
//  MHGradientView.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHGradientView.h"

@implementation MHGradientView

-(instancetype)init{
    self =  [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSArray* gradientBlackClearColors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.85].CGColor,
                                          (id)[[UIColor blackColor] colorWithAlphaComponent:0.70].CGColor,
                                          (id)[[UIColor blackColor] colorWithAlphaComponent:0.0].CGColor
                                          ];
    
    CGFloat gradientBlackClearLocations[] = {0, 0.5, 1};
    CGGradientRef glossGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientBlackClearColors, gradientBlackClearLocations);
    
    CGRect currentBounds = self.bounds;
    
    CGContextDrawLinearGradient(currentContext, glossGradient, CGPointMake(CGRectGetWidth(currentBounds)*0.5, CGRectGetHeight(currentBounds)), CGPointMake(CGRectGetWidth(currentBounds)*0.5, 0), 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
