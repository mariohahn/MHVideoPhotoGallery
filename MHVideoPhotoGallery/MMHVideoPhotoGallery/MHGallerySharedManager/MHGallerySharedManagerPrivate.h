//
//  MHGallerySharedManagerPrivate.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGallerySharedManager ()

+ (UIImage *)imageByRenderingView:(id)view;

+ (NSString*)stringForMinutesAndSeconds:(NSInteger)seconds
                               addMinus:(BOOL)addMinus;

@end
