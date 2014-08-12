//
//  UIImageView+MHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHGalleryItem;

typedef NS_ENUM(NSUInteger, MHImageType) {
    MHImageTypeThumb,
    MHImageTypeFull
};


@interface UIImageView (MHGallery)

-(void)setThumbWithURL:(NSString*)URL
          successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock;

-(void)setImageForMHGalleryItem:(MHGalleryItem*)item
                      imageType:(MHImageType)imageType
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock;
@end
