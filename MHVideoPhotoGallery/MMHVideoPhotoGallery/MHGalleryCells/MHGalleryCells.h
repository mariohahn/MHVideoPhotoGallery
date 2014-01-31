//
//  MHGalleryCells.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHGalleryOverViewCell : UICollectionViewCell
@property (nonatomic, strong)UIImageView *iv;
@property (nonatomic, strong)UIActivityIndicatorView *act;
@property (nonatomic, strong)UIButton *playButton;
@property (nonatomic, strong)UILabel *videoDurationLength;
@property (nonatomic, strong)UIImageView *videoIcon;
@property (nonatomic, strong)UIView *videoGradient;
@property (nonatomic, strong)UIImageView *selectionImageView;

@property (nonatomic, copy) void (^saveImage)(BOOL shouldSave);
@end

@interface MHShareCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *iv;
@property (strong, nonatomic) UILabel *labelDescription;
@end

@interface MHGalleryCollectionViewCell : UITableViewCell
@property (strong, nonatomic) UICollectionView *collectionView;
@end
