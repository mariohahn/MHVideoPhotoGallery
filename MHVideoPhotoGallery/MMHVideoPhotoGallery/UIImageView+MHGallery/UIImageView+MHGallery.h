//
//  UIImageView+MHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MHGallery)

-(void)setThumbWithURL:(NSString*)URL
          successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock;

@end
