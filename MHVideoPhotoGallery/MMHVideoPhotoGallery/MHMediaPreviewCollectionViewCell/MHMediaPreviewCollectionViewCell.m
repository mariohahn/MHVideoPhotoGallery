//
//  MHGalleryCells.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHMediaPreviewCollectionViewCell.h"
#import "MHGallery.h"
#import "MHGallerySharedManagerPrivate.h"

@implementation MHMediaPreviewCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        _thumbnail = [UIImageView.alloc initWithFrame:self.bounds];
        self.thumbnail.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.clipsToBounds = YES;
        [self.contentView addSubview:self.thumbnail];
        
        _activityIndicator = [UIActivityIndicatorView.alloc initWithFrame:self.bounds];
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.activityIndicator.color = UIColor.whiteColor;
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.tag = 405;
        [self.contentView addSubview:self.activityIndicator];
        
        _playButton = [UIButton.alloc initWithFrame:self.bounds];
        
        [self.playButton setImage:MHGalleryImage(@"playButton") forState:UIControlStateNormal];
        self.playButton.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.playButton.tag = 406;
        self.playButton.hidden = YES;
        [self.contentView addSubview:self.playButton];
        
        
        _videoGradient = [UIView.alloc initWithFrame:CGRectMake(0, self.bounds.size.height-30,  self.bounds.size.width, 30)];
        self.videoGradient.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        self.videoGradient.hidden = YES;
       
        CAGradientLayer *gradient = CAGradientLayer.layer;
        gradient.frame = self.videoGradient.bounds;
        gradient.colors = @[(id) UIColor.clearColor.CGColor,
                            (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor,
                            (id)[UIColor colorWithWhite:0 alpha:1.0].CGColor];
        
        [self.videoGradient.layer insertSublayer:gradient atIndex:0];
        [self.contentView addSubview:self.videoGradient];
        
        _videoDurationLength = [UILabel.alloc initWithFrame:CGRectMake(0, self.bounds.size.height-25, self.bounds.size.width-5, 30)];
        self.videoDurationLength.textAlignment = NSTextAlignmentRight;
        self.videoDurationLength.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
        self.videoDurationLength.backgroundColor = UIColor.clearColor;
        self.videoDurationLength.textColor = UIColor.whiteColor;
        self.videoDurationLength.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.videoDurationLength];
        

        _videoIcon = [UIImageView.alloc initWithFrame:CGRectMake(5,  self.bounds.size.height-20, 15, 20)];
        self.videoIcon.image = MHGalleryImage(@"videoIcon");
        self.videoIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.videoIcon.hidden = YES;
        [self.contentView addSubview:self.videoIcon];
        
        _selectionImageView = [UIImageView.alloc initWithFrame:CGRectMake(self.bounds.size.width-30,  self.bounds.size.height-30, 22, 22)];
        self.selectionImageView.image = MHGalleryImage(@"videoIcon");
        self.selectionImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.selectionImageView.hidden = YES;
        [self.contentView addSubview:self.selectionImageView];
        
    }
    return self;
}
-(void)setGalleryItem:(MHGalleryItem *)galleryItem{
    
    __weak typeof(self) weakSelf = self;

    [self.activityIndicator startAnimating];

    if (galleryItem.galleryType == MHGalleryTypeVideo) {
        [MHGallerySharedManager.sharedManager startDownloadingThumbImage:galleryItem.URLString
                                                            successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error) {
                                                                if (error) {
                                                                    weakSelf.thumbnail.backgroundColor = UIColor.whiteColor;
                                                                    weakSelf.thumbnail.image = MHGalleryImage(@"error");
                                                                }else{
                                                                    weakSelf.videoDurationLength.text  = [MHGallerySharedManager stringForMinutesAndSeconds:videoDuration addMinus:NO];
                                                                    
                                                                    weakSelf.thumbnail.image = image;
                                                                    weakSelf.videoIcon.hidden = NO;
                                                                    weakSelf.videoGradient.hidden = NO;
                                                                }
                                                                [weakSelf.activityIndicator stopAnimating];
                                                            }];
    }else{
        [self.thumbnail setImageForMHGalleryItem:galleryItem imageType:MHImageTypeThumb successBlock:^(UIImage *image, NSError *error) {
            [weakSelf.activityIndicator stopAnimating];
            if (!image) {
                weakSelf.thumbnail.backgroundColor = UIColor.whiteColor;
                weakSelf.thumbnail.image = MHGalleryImage(@"error");
            }
        }];
        
    }
    _galleryItem = galleryItem;
}

- (void)saveImage:(id)sender {
    self.saveImage(YES);
}

@end



