//
//  UIImageView+MHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "UIImageView+MHGallery.h"
#import "MHGalleryGlobals.h"

@implementation UIImageView (MHGallery)

-(void)setThumbWithURL:(NSString*)URL
          successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock{
    [[MHGallerySharedManager sharedManager]startDownloadingThumbImage:URL
                                                         successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error, NSString *newURL) {
                                                             self.image = image;
    }];
}


@end
