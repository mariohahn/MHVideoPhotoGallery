//
//  MHGalleryPresenterImageView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGalleryPresenterImageView : UIImageView
@property (nonatomic,strong) NSArray   *galleryItems;
@property (nonatomic)        NSInteger currentImageIndex;
@property (nonatomic, copy) void (^finishedCallback)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image);
@end
