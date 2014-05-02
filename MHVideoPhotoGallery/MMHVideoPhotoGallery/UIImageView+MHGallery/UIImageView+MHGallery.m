//
//  UIImageView+MHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 06.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "UIImageView+MHGallery.h"
#import "MHGallery.h"
#import "SDImageCache.h"

@implementation UIImageView (MHGallery)

-(void)setThumbWithURL:(NSString*)URL
          successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock{
    
    __weak typeof(self) weakSelf = self;
    
    [MHGallerySharedManager.sharedManager startDownloadingThumbImage:URL
                                                        successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                                                            
                                                            if (!weakSelf) return;
                                                            dispatch_main_sync_safe(^{
                                                                if (!weakSelf) return;
                                                                if (image){
                                                                    weakSelf.image = image;
                                                                    [weakSelf setNeedsLayout];
                                                                }
                                                                if (succeedBlock) {                                                                     succeedBlock(image,videoDuration,error);
                                                                }
                                                            });
                                                        }];
}

-(void)setImageForMHGalleryItem:(MHGalleryItem*)item
                      imageType:(MHImageType)imageType
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock{
    
    __weak typeof(self) weakSelf = self;
    
    if ([item.URLString rangeOfString:MHAssetLibrary].location != NSNotFound && item.URLString) {
        
        MHAssetImageType assetType = MHAssetImageTypeThumb;
        if (imageType == MHImageTypeFull) {
            assetType = MHAssetImageTypeFull;
        }
        
        [MHGallerySharedManager.sharedManager getImageFromAssetLibrary:item.URLString
                                                             assetType:assetType
                                                          successBlock:^(UIImage *image, NSError *error) {
                                                              [weakSelf setImageForImageView:image successBlock:succeedBlock];
                                                          }];
    }else if(item.image){
        [self setImageForImageView:item.image successBlock:succeedBlock];
    }else{
        
        NSString *placeholderURL = item.thumbnailURL;
        NSString *toLoadURL = item.URLString;

        if (imageType == MHImageTypeThumb) {
            toLoadURL = item.thumbnailURL;
            placeholderURL = item.URLString;
        }
        
        [self setImageWithURL:[NSURL URLWithString:toLoadURL]
             placeholderImage:[SDImageCache.sharedImageCache imageFromDiskCacheForKey:placeholderURL]
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (succeedBlock) {
                succeedBlock (image,error);
            }
        }];
    }
}


-(void)setImageForImageView:(UIImage*)image
               successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock{
    
    __weak typeof(self) weakSelf = self;
    
    if (!weakSelf) return;
    dispatch_main_sync_safe(^{
        weakSelf.image = image;
        [weakSelf setNeedsLayout];
        if (succeedBlock) {
            succeedBlock(image,nil);
        }
    });
}



@end
